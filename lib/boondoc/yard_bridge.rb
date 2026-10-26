# frozen_string_literal: true

module Boondoc
  # Optional second pass that uses YARD to expand macros and directives.
  #
  # Prism stays the source of truth. YARD only contributes objects that Prism
  # could not see (those created by `@!method`, `@!attribute`, or an attached
  # macro) and the expanded docstrings of objects whose comment uses a directive.
  #
  # The `yard` gem is loaded on demand and is not a dependency of boondoc.
  class YardBridge
    DEFAULT_SUPERCLASSES = %w[Object BasicObject].freeze
    # The "error" severity, which has the same value in every YARD logger implementation.
    ERROR_LEVEL = 3

    # @param registry [Model::Registry]
    # @param reporter [Reporter]
    def initialize(registry, reporter)
      @registry = registry
      @reporter = reporter
    end

    # @param files [Array<String>] the Ruby files that contain YARD directives, relative to `root`
    # @param root [String] the project directory. YARD is given absolute paths, so the
    #   working directory does not matter, and the files it records are made relative again.
    # @return [Integer] how many objects were added from YARD
    # @raise [Error] when the yard gem is not installed
    def merge(files, root:)
      load_yard
      @root = File.expand_path(root)
      @added = 0
      ::YARD::Registry.clear
      paths = files.map { |file| File.expand_path(file, @root) }
      ::YARD::Logger.instance.enter_level(ERROR_LEVEL) { ::YARD.parse(paths) }
      yard_objects.each { |object| merge_object(object) }
      @added
    ensure
      ::YARD::Registry.clear if defined?(::YARD::Registry)
    end

    private

    def load_yard
      require 'yard'
    rescue LoadError
      raise Error, "--yard-macros needs the yard gem. Add `gem 'yard'` to your Gemfile or run `gem install yard`."
    end

    def yard_objects
      namespaces = ::YARD::Registry.all(:module, :class).sort_by { |object| object.path.count(':') }
      namespaces + ::YARD::Registry.all(:constant, :method)
    end

    def merge_object(yard_object)
      existing = @registry[yard_object.path]
      return add(yard_object) unless existing

      existing.docstring = docstring(yard_object) if existing.docstring.directives.any?
    end

    def add(yard_object)
      namespace = @registry[yard_object.namespace.path]
      return unless namespace.is_a?(Model::NamespaceObject)

      object = build(yard_object, namespace)
      object.visibility = yard_object.visibility
      object.docstring = docstring(yard_object)
      object.add_file(relative(yard_object.file), yard_object.line) if yard_object.file
      @registry.register(object)
      @added += 1
    end

    def relative(file)
      prefix = File.join(@root, '')
      file.start_with?(prefix) ? file.delete_prefix(prefix) : file
    end

    def build(yard_object, namespace)
      name = yard_object.name.to_s
      case yard_object.type
      when :constant then Model::ConstantObject.new(name, namespace, value: yard_object.value.to_s)
      when :method then build_method(yard_object, name, namespace)
      else build_namespace(yard_object, name, namespace)
      end
    end

    def build_namespace(yard_object, name, namespace)
      object = Model::NamespaceObject.new(name, namespace, kind: yard_object.type)
      superclass = yard_object.superclass&.path if yard_object.type == :class
      object.superclass = superclass unless DEFAULT_SUPERCLASSES.include?(superclass)
      object
    end

    def build_method(yard_object, name, namespace)
      attribute = (name.end_with?('=') ? :writer : :reader) if yard_object.is_attribute?
      Model::MethodObject.new(name, namespace, scope: yard_object.scope, attribute: attribute,
                                               parameters: parameters(yard_object))
    end

    def parameters(yard_object)
      list = yard_object.parameters.map do |name, default|
        next name.to_s unless default

        name.to_s.end_with?(':') ? "#{name} #{default}" : "#{name} = #{default}"
      end
      list.empty? ? nil : list.join(', ')
    end

    def docstring(yard_object)
      DocstringParser.parse(yard_object.docstring.to_raw)
    end
  end
end
