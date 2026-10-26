# frozen_string_literal: true

module Boondoc
  module Frontend
    # Walks a Prism tree and registers namespaces, methods, and constants.
    #
    # Method bodies are never entered, so only definitions made at class, module
    # or top level are documented.
    class Visitor < ::Prism::Visitor # rubocop:disable Metrics/ClassLength -- one handler per Ruby construct
      # The state that applies while visiting one namespace body.
      Frame = Struct.new(:namespace, :visibility, :singleton, :module_function)

      CALLS = {
        attr: :on_attr, attr_reader: :on_attr, attr_writer: :on_attr, attr_accessor: :on_attr,
        public: :on_visibility, protected: :on_visibility, private: :on_visibility,
        private_class_method: :on_class_visibility, public_class_method: :on_class_visibility,
        module_function: :on_module_function, private_constant: :on_private_constant,
        alias_method: :on_alias_method, define_method: :on_define_method,
        include: :on_mixin, extend: :on_mixin, prepend: :on_mixin
      }.freeze
      ALWAYS_PRIVATE = %w[initialize_copy initialize_clone initialize_dup respond_to_missing?].freeze
      ATTR_READERS_ONLY = %i[attr attr_reader].freeze
      ANONYMOUS = { 'Struct' => :new, 'Data' => :define, 'Class' => :new, 'Module' => :new }.freeze

      # @param registry [Model::Registry]
      # @param file [String] file name recorded on each object
      # @param comments [Comments]
      def initialize(registry, file, comments)
        super()
        @registry = registry
        @file = file
        @comments = comments
        @frames = [Frame.new(registry.root, :public, false, false)]
        @visibility_override = nil
      end

      def visit_module_node(node)
        open_namespace(node, :module, nil)
      end

      def visit_class_node(node)
        open_namespace(node, :class, node.superclass&.slice)
      end

      def visit_singleton_class_node(node)
        return unless node.expression.is_a?(::Prism::SelfNode)

        with_frame(frame.namespace, singleton: true) { visit(node.body) }
      end

      def visit_def_node(node)
        explicit = !node.receiver.nil?
        scope = def_scope(node)
        return unless scope

        add_method(node.name.to_s, scope, line(node), parameters: node.parameters&.slice, explicit: explicit)
      end

      def visit_call_node(node)
        handler = CALLS[node.name]
        return super unless handler && (node.receiver.nil? || node.receiver.is_a?(::Prism::SelfNode))

        send(handler, node)
      end

      def visit_alias_method_node(node)
        return unless node.new_name.is_a?(::Prism::SymbolNode) && node.old_name.is_a?(::Prism::SymbolNode)

        add_alias(node.new_name.unescaped, node.old_name.unescaped, line(node))
      end

      def visit_constant_write_node(node)
        return if @comments.nodoc?(line(node))

        value = node.value
        return define_anonymous(node, value) if anonymous_namespace?(value)

        constant = Model::ConstantObject.new(node.name.to_s, frame.namespace, value: value.slice)
        @registry.register(constant)
        document(constant, line(node))
      end

      private

      def frame
        @frames.last
      end

      def line(node)
        node.location.start_line
      end

      # The scope of methods defined by calls such as `attr_reader` and `alias_method`.
      def current_scope
        frame.singleton ? :class : :instance
      end

      def find_method(scope, name)
        @registry[Model::MethodObject.path_for(frame.namespace, scope, name)]
      end

      def with_frame(namespace, singleton: false)
        @frames.push(Frame.new(namespace, :public, singleton, false))
        yield
      ensure
        @frames.pop
      end

      def with_visibility(visibility)
        previous = @visibility_override
        @visibility_override = visibility
        yield
      ensure
        @visibility_override = previous
      end

      # --- namespaces ---------------------------------------------------------

      def open_namespace(node, kind, superclass)
        return if @comments.nodoc?(line(node))

        namespace = ensure_namespace(node.constant_path.slice, kind)
        namespace.superclass ||= superclass
        document(namespace, line(node))
        with_frame(namespace) { visit(node.body) }
      end

      def ensure_namespace(name, kind)
        parts = name.delete_prefix('::').split('::')
        parent = namespace_base(name, parts)
        parts.each_with_index do |part, index|
          last = index == parts.size - 1
          parent = child_namespace(parent, part, last ? kind : :module, placeholder: !last)
        end
        parent
      end

      # Where a (possibly qualified) name is looked up from: the root for `::Foo`,
      # the namespace that already holds the first segment for `Foo::Bar`, and
      # the current namespace otherwise.
      def namespace_base(name, parts)
        return @registry.root if name.start_with?('::')
        return frame.namespace if parts.size == 1

        @registry.resolve(frame.namespace, parts.first)&.namespace || frame.namespace
      end

      def child_namespace(parent, name, kind, placeholder:)
        path = parent.root? ? name : "#{parent.path}::#{name}"
        existing = @registry[path]
        if existing.is_a?(Model::NamespaceObject)
          existing.kind = kind unless placeholder
          return existing
        end

        @registry.register(Model::NamespaceObject.new(name, parent, kind: kind))
      end

      def anonymous_namespace?(value)
        value.is_a?(::Prism::CallNode) && value.receiver &&
          ANONYMOUS[value.receiver.slice.delete_prefix('::')] == value.name
      end

      # `Foo = Struct.new(:a)`, `Foo = Data.define(:a)`, `Foo = Class.new(Base)`
      def define_anonymous(node, value)
        receiver = value.receiver.slice.delete_prefix('::')
        namespace = ensure_namespace(node.name.to_s, receiver == 'Module' ? :module : :class)
        namespace.superclass ||= anonymous_superclass(receiver, value)
        document(namespace, line(node))
        with_frame(namespace) do
          define_members(receiver, value, line(node))
          visit(value.block.body) if value.block.is_a?(::Prism::BlockNode)
        end
      end

      def anonymous_superclass(receiver, value)
        return receiver if %w[Struct Data].include?(receiver)
        return nil unless receiver == 'Class'

        first = arguments(value).first
        first.slice if first.is_a?(::Prism::ConstantReadNode) || first.is_a?(::Prism::ConstantPathNode)
      end

      def define_members(receiver, value, line)
        return unless %w[Struct Data].include?(receiver)

        arguments(value).grep(::Prism::SymbolNode).each do |member|
          add_method(member.unescaped, :instance, line, attribute: :reader, documented: false)
          next if receiver == 'Data'

          add_method("#{member.unescaped}=", :instance, line, attribute: :writer, documented: false)
        end
      end

      # --- methods ------------------------------------------------------------

      def def_scope(node)
        case node.receiver
        when nil then frame.singleton || frame.module_function ? :class : :instance
        when ::Prism::SelfNode then :class
        else :class if [frame.namespace.name, frame.namespace.path].include?(node.receiver.slice)
        end
      end

      def add_method(name, scope, line, explicit: false, documented: true, **)
        return if @comments.nodoc?(line)

        meth = Model::MethodObject.new(name, frame.namespace, scope: scope, **)
        meth.visibility = method_visibility(name, scope, explicit)
        previous = @registry[meth.path]
        @registry.register(meth)
        meth.add_file(@file, line)
        document(meth, line) if documented
        meth.docstring = previous.docstring if previous && meth.docstring.empty?
        meth
      end

      def method_visibility(name, scope, explicit)
        return @visibility_override if @visibility_override
        return :private if scope == :instance && ALWAYS_PRIVATE.include?(name)
        return :public if explicit || frame.module_function

        frame.visibility
      end

      def add_alias(new_name, old_name, line)
        scope = current_scope
        original = find_method(scope, old_name)
        meth = add_method(new_name, scope, line, parameters: original&.parameters, alias_for: old_name)
        return unless meth && original

        # An alias copies the original's visibility, unless wrapped as in `private alias_method ...`.
        meth.visibility = original.visibility unless @visibility_override
        meth.docstring = original.docstring if meth.docstring.empty?
      end

      # --- call handlers ------------------------------------------------------

      def on_attr(node)
        scope = current_scope
        names(node).each do |name|
          add_method(name, scope, line(node), attribute: :reader) unless node.name == :attr_writer
          next if ATTR_READERS_ONLY.include?(node.name)

          add_method("#{name}=", scope, line(node), attribute: :writer)
        end
      end

      def on_visibility(node)
        args = arguments(node)
        if args.empty?
          frame.visibility = node.name
          frame.module_function = false
          return
        end

        apply_visibility(args, node.name, current_scope)
      end

      def on_class_visibility(node)
        visibility = node.name == :private_class_method ? :private : :public
        apply_visibility(arguments(node), visibility, :class)
      end

      def apply_visibility(args, visibility, scope)
        args.each do |arg|
          case arg
          when ::Prism::ArrayNode then apply_visibility(arg.elements, visibility, scope)
          when ::Prism::DefNode, ::Prism::CallNode then with_visibility(visibility) { visit(arg) }
          else change_visibility(literal(arg), visibility, scope)
          end
        end
      end

      def change_visibility(name, visibility, scope)
        meth = name && find_method(scope, name)
        meth.visibility = visibility if meth
      end

      def on_module_function(node)
        args = arguments(node)
        return frame.module_function = true if args.empty?

        args.each do |arg|
          next promote_to_class_method(literal(arg)) unless arg.is_a?(::Prism::DefNode)

          # A bare `module_function` earlier in the body stays in effect afterwards.
          previous = frame.module_function
          frame.module_function = true
          visit(arg)
          frame.module_function = previous
        end
      end

      def promote_to_class_method(name)
        original = name && find_method(:instance, name)
        return unless original

        @registry.delete(original)
        meth = Model::MethodObject.new(name, frame.namespace, scope: :class, parameters: original.parameters)
        meth.docstring = original.docstring
        original.files.each { |file, line| meth.add_file(file, line) }
        @registry.register(meth)
      end

      def on_private_constant(node)
        names(node).each do |name|
          constant = @registry[frame.namespace.root? ? name : "#{frame.namespace.path}::#{name}"]
          constant.visibility = :private if constant
        end
      end

      def on_alias_method(node)
        new_name, old_name = names(node)
        add_alias(new_name, old_name, line(node)) if new_name && old_name
      end

      def on_define_method(node)
        name = literal(arguments(node).first)
        return unless name && node.block.is_a?(::Prism::BlockNode)

        add_method(name, current_scope, line(node), parameters: node.block.parameters&.parameters&.slice)
      end

      def on_mixin(node)
        kind = frame.singleton && node.name == :include ? :extend : node.name
        arguments(node).each do |arg|
          next unless arg.is_a?(::Prism::ConstantReadNode) || arg.is_a?(::Prism::ConstantPathNode)

          list = frame.namespace.mixins[kind]
          list << arg.slice unless list.include?(arg.slice)
        end
      end

      # --- helpers ------------------------------------------------------------

      def arguments(node)
        node.arguments&.arguments || []
      end

      def names(node)
        arguments(node).filter_map { |arg| literal(arg) }
      end

      def literal(node)
        node.unescaped if node.is_a?(::Prism::SymbolNode) || node.is_a?(::Prism::StringNode)
      end

      def document(object, line)
        object.add_file(@file, line)
        text = @comments.docstring_for(line)
        return unless text

        docstring = DocstringParser.parse(text)
        object.docstring = docstring if object.docstring.empty?
      end
    end
  end
end
