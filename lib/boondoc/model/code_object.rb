# frozen_string_literal: true

module Boondoc
  module Model
    # Base class for everything that can be documented.
    class CodeObject
      # @return [String] the unqualified name
      attr_reader :name
      # @return [NamespaceObject, nil] the enclosing namespace (nil only for the root)
      attr_reader :namespace
      # @return [Docstring]
      attr_accessor :docstring
      # @return [Symbol] `:public`, `:protected`, or `:private`
      attr_accessor :visibility
      # @return [Array<Array(String, Integer)>] `[file, line]` pairs where the object is defined
      attr_reader :files

      # @param name [String]
      # @param namespace [NamespaceObject, nil]
      def initialize(name, namespace)
        @name = name
        @namespace = namespace
        @docstring = Docstring.new
        @visibility = :public
        @files = []
      end

      # @return [String] the fully qualified path, such as `Foo::Bar#baz`
      def path
        (namespace.nil? || namespace.root?) ? name : "#{namespace.path}::#{name}"
      end

      # @return [Boolean]
      def root?
        false
      end

      # Records a definition site, ignoring duplicates.
      #
      # @param file [String]
      # @param line [Integer]
      # @return [void]
      def add_file(file, line)
        files << [file, line] unless files.any? { |existing, _| existing == file }
      end

      # @return [Boolean] true when tagged `@private` or `@api private`
      def private_api?
        docstring.tag?("private") || docstring.tags_named("api").any? { |tag| tag.text.strip == "private" }
      end
    end

    # A class, a module, or the top-level namespace.
    class NamespaceObject < CodeObject
      # @return [Symbol] `:class`, `:module`, or `:root`
      attr_accessor :kind
      # @return [String, nil] the superclass as written in source
      attr_accessor :superclass
      # @return [Hash{Symbol => Array<String>}] mixin names keyed by `:include`, `:extend`, `:prepend`
      attr_reader :mixins
      # @return [Array<CodeObject>] everything defined directly inside this namespace
      attr_reader :children

      # @param name [String]
      # @param namespace [NamespaceObject, nil]
      # @param kind [Symbol]
      def initialize(name, namespace, kind: :module)
        super(name, namespace)
        @kind = kind
        @mixins = { include: [], extend: [], prepend: [] }
        @children = []
      end

      # @return [String] empty for the root
      def path
        root? ? "" : super
      end

      # @return [Boolean]
      def root?
        kind == :root
      end

      # @return [Array<NamespaceObject>] nested classes and modules, sorted by name
      def namespaces
        children.grep(NamespaceObject).sort_by(&:name)
      end

      # @return [Array<ConstantObject>] constants, sorted by name
      def constants
        children.grep(ConstantObject).sort_by(&:name)
      end

      # @param scope [Symbol] `:instance` or `:class`
      # @return [Array<MethodObject>] methods in that scope, `initialize` first, then by name
      def meths(scope)
        children.grep(MethodObject).select { |meth| meth.scope == scope }
          .sort_by { |meth| [(meth.name == "initialize") ? 0 : 1, meth.name] }
      end
    end

    # A method or attribute.
    class MethodObject < CodeObject
      # @return [Symbol] `:instance` or `:class`
      attr_reader :scope
      # @return [String, nil] the parameter list as written, without parentheses
      attr_accessor :parameters
      # @return [Symbol, nil] `:reader` or `:writer` when defined by `attr_*`
      attr_reader :attribute
      # @return [String, nil] name of the method this one aliases
      attr_reader :alias_for

      # @param name [String]
      # @param namespace [NamespaceObject]
      # @param scope [Symbol]
      # @param parameters [String, nil]
      # @param attribute [Symbol, nil]
      # @param alias_for [String, nil]
      def initialize(name, namespace, scope: :instance, parameters: nil, attribute: nil, alias_for: nil)
        super(name, namespace)
        @scope = scope
        @parameters = parameters
        @attribute = attribute
        @alias_for = alias_for
      end

      # @param namespace [NamespaceObject]
      # @param scope [Symbol] `:instance` or `:class`
      # @param name [String]
      # @return [String] the path a method with that name and scope would have
      def self.path_for(namespace, scope, name)
        "#{namespace.path}#{(scope == :class) ? "." : "#"}#{name}"
      end

      # @return [String] `#` for instance methods, `.` for class methods
      def separator
        (scope == :class) ? "." : "#"
      end

      # @return [String]
      def path
        self.class.path_for(namespace, scope, name)
      end

      # @return [String] the name with its separator, such as `#each`
      def display_name
        "#{separator}#{name}"
      end
    end

    # A constant that is not a class or module.
    class ConstantObject < CodeObject
      # @return [String] the source of the assigned value
      attr_reader :value

      # @param name [String]
      # @param namespace [NamespaceObject]
      # @param value [String]
      def initialize(name, namespace, value: "")
        super(name, namespace)
        @value = value
      end
    end
  end
end
