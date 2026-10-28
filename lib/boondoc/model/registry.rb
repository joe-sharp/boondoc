# frozen_string_literal: true

module Boondoc
  module Model
    # Every documented object, keyed by path, with YARD-style reference lookup.
    class Registry
      include Enumerable

      REFERENCE = /\A(?<const>(?:::)?[A-Z]\w*(?:::[A-Z]\w*)*)?(?:(?<sep>#|\.|::)(?<meth>[^A-Z:].*))?\z/

      # @return [NamespaceObject] the top-level namespace
      attr_reader :root
      # @return [Array<String>] `file:line` locations of comments that use YARD directives
      attr_reader :directive_sites

      def initialize
        @root = NamespaceObject.new("", nil, kind: :root)
        @objects = { "" => @root }
        @directive_sites = []
      end

      # @return [Array<String>] the files that contain YARD directives, in the order they were parsed
      def directive_files
        @directive_sites.map { |site| site.rpartition(":").first }.uniq
      end

      # @param path [String]
      # @return [CodeObject, nil]
      def [](path)
        @objects[path]
      end

      # Adds an object, replacing any existing object at the same path.
      #
      # @param object [CodeObject]
      # @return [CodeObject] the object
      def register(object)
        delete(@objects[object.path])
        @objects[object.path] = object
        object.namespace.children << object
        object
      end

      # @param object [CodeObject, nil]
      # @return [void]
      def delete(object)
        return unless object

        @objects.delete(object.path)
        object.namespace&.children&.delete(object)
      end

      # @yieldparam object [CodeObject]
      def each(&)
        @objects.values.each(&)
      end

      # Resolves a reference such as `Foo::Bar`, `Foo#bar`, `#bar`, or `bar` as
      # seen from `context`, searching enclosing namespaces and ancestors.
      #
      # @param context [CodeObject] where the reference was written
      # @param reference [String]
      # @return [CodeObject, nil]
      def resolve(context, reference)
        reference = reference.to_s.strip
        match = REFERENCE.match(reference) || /\A(?<const>)(?<sep>)(?<meth>\S+)\z/.match(reference)
        return nil if reference.empty? || match.nil?

        start = context.is_a?(NamespaceObject) ? context : context.namespace
        resolve_parts(start, match[:const].to_s, match[:sep].to_s, match[:meth])
      end

      # @param namespace [NamespaceObject]
      # @return [Array<NamespaceObject>] the namespace followed by its documented
      #   mixins and superclasses, nearest first
      def ancestors(namespace)
        seen = [namespace]
        seen.each do |current|
          mixins = (current.mixins[:prepend] + current.mixins[:include]).map { |name| resolve_constant(current, name) }
          [*mixins, superclass(current)].each do |found|
            seen << found if found.is_a?(NamespaceObject) && !seen.include?(found)
          end
        end
        seen
      end

      # Like Ruby, looks the superclass up from the scope around the class, and
      # never finds the class itself, so `class Error < Error` inside a module
      # refers to an outer `Error`.
      #
      # @param namespace [NamespaceObject]
      # @return [NamespaceObject, nil] the documented superclass
      def superclass(namespace)
        return nil unless namespace.superclass && namespace.namespace

        found = resolve_constant(namespace.namespace, namespace.superclass, except: namespace)
        found if found.is_a?(NamespaceObject)
      end

      private

      def resolve_parts(start, const, sep, meth)
        return resolve_constant(start, const) if meth.nil?
        return find_method(resolve_constant(start, const), sep, meth) unless const.empty?

        lexical(start).each do |scope|
          found = find_method(scope, sep, meth)
          return found if found
        end
        nil
      end

      def resolve_constant(start, const, except: nil)
        constant_candidates(start, const).each do |path|
          found = self[path]
          return found if found && !found.equal?(except)
        end
        nil
      end

      def constant_candidates(start, const)
        return [const.delete_prefix("::")] if const.start_with?("::")

        lexical(start).map { |scope| scope.root? ? const : "#{scope.path}::#{const}" }
      end

      def find_method(namespace, sep, meth)
        return nil unless namespace.is_a?(NamespaceObject)

        separators = { "" => %w[# .], "#" => ["#"] }.fetch(sep, ["."])
        ancestors(namespace).each do |ancestor|
          separators.each do |separator|
            found = self["#{ancestor.path}#{separator}#{meth}"]
            return found if found
          end
        end
        nil
      end

      def lexical(namespace)
        scopes = []
        while namespace
          scopes << namespace
          namespace = namespace.namespace
        end
        scopes
      end
    end
  end
end
