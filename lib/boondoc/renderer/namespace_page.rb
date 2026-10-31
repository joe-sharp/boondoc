# frozen_string_literal: true

module Boondoc
  module Renderer
    # Renders the page for one class or module, or for the top-level namespace.
    class NamespacePage < Base
      SCOPES = { class: "Class methods", instance: "Instance methods" }.freeze
      MIXINS = { include: "Includes", extend: "Extended by", prepend: "Prepended by" }.freeze
      MAX_CONSTANT_LINES = 12
      # A guard against a superclass chain that never ends; real chains are far shorter.
      MAX_SUPERCLASS_CHAIN = 20

      # @param context [Context]
      # @param namespace [Model::NamespaceObject]
      def initialize(context, namespace)
        super(context)
        @namespace = namespace
        @from = path_map.file_for(namespace)
        @methods = MethodSection.new(context, @from)
      end

      # @return [Boolean] false when there is nothing worth writing a page for
      def content?
        !@namespace.root? || visible(@namespace.children.grep_v(Model::NamespaceObject)).any?
      end

      # @return [String] the whole page
      def render
        document([
          "# #{title}",
          facts,
          Docstring.new(context, @namespace, @from).render(@namespace.docstring),
          namespaces,
          constants,
          attributes,
          SCOPES.keys.map { |scope| method_sections(scope) },
          inherited_methods
        ])
      end

      private

      def visible(objects)
        objects.select { |object| filter.visible?(object) }
      end

      def title
        return "Top level" if @namespace.root?

        "#{@namespace.kind.to_s.capitalize}: #{@namespace.path}"
      end

      # --- header -------------------------------------------------------------

      def facts
        lines = []
        lines << "- **Inherits:** #{superclass_chain.join(" < ")}" if @namespace.superclass
        lines.concat(mixin_facts)
        lines << "- **Defined in:** #{source_links.join(", ")}" unless @namespace.files.empty?
        lines.join("\n") unless lines.empty?
      end

      def mixin_facts
        MIXINS.filter_map do |kind, label|
          names = @namespace.mixins[kind]
          "- **#{label}:** #{names.map { |name| constant_link(name) }.join(", ")}" unless names.empty?
        end
      end

      def constant_link(name)
        found = registry.resolve(@namespace, name)
        found.is_a?(Model::NamespaceObject) ? linker.link(found, from: @from) : code(name)
      end

      def superclass_chain
        chain = []
        current = @namespace
        while current&.superclass && chain.size < MAX_SUPERCLASS_CHAIN
          found = registry.superclass(current)
          chain << (found ? linker.link(found, from: @from) : code(current.superclass))
          current = found
          break if current.equal?(@namespace)
        end
        chain
      end

      def source_links
        @namespace.files.map { |file, _| "[#{code(file)}](#{path_map.source_href(file, from: @from)})" }
      end

      # --- sections -----------------------------------------------------------

      def namespaces
        children = visible(@namespace.namespaces)
        return nil if children.empty?

        ["## Namespaces",
         children.map { |child|
           bullet(
             linker.link(child, from: @from),
             summary(child, @from)
           )
         }.join("\n")]
      end

      def constants
        constants = visible(@namespace.constants)
        return nil if constants.empty?

        ["## Constants", *constants.flat_map { |constant| constant_section(constant) }]
      end

      def constant_section(constant)
        [
          %(### <a id="#{path_map.anchor_for(constant)}"></a>#{code(constant.name)}),
          ruby("#{constant.name} = #{truncate(constant.value)}"),
          *Docstring.new(context, constant, @from).render(constant.docstring)
        ]
      end

      def truncate(value)
        lines = value.lines
        return value if lines.size <= MAX_CONSTANT_LINES

        "#{lines.first(MAX_CONSTANT_LINES).join.rstrip}\n# ... (#{lines.size - MAX_CONSTANT_LINES} more lines)"
      end

      def attributes
        groups = SCOPES.keys.flat_map do |scope|
          visible(context.meths(@namespace, scope)).select(&:attribute)
            .group_by { |meth| meth.name.delete_suffix("=") }.values
        end
        return nil if groups.empty?

        ["## Attributes", *groups.flat_map { |accessors| @methods.render_attribute(accessors) }]
      end

      def method_sections(scope)
        meths = visible(context.meths(@namespace, scope)).reject(&:attribute)
        return nil if meths.empty?

        ["## #{SCOPES[scope]}", summary_table(meths), *meths.flat_map { |meth| @methods.render(meth) }]
      end

      def summary_table(meths)
        rows = meths.map do |meth|
          label = Markdown.table_cell(@methods.signature(meth).delete_prefix("def ").delete_prefix("self."))
          "| [#{code("#{meth.separator}#{label}")}](#{path_map.href(meth, from: @from)}) | #{summary(meth, @from)} |"
        end
        ["| Method | Summary |", "| --- | --- |", *rows].join("\n")
      end

      # Each method is listed under the nearest ancestor that defines it, the
      # one Ruby would actually call.
      def inherited_methods
        seen = context.meths(@namespace, :instance).to_set(&:name)
        items = registry.ancestors(@namespace).drop(1).filter_map { |ancestor| inherited_from_ancestor(ancestor, seen) }
        ["## Inherited methods", items.join("\n")] unless items.empty?
      end

      def inherited_from_ancestor(ancestor, seen)
        meths = context.meths(ancestor, :instance).reject { |meth| seen.include?(meth.name) }
        seen.merge(meths.map(&:name))
        inherited_from(ancestor, visible(meths)) if filter.visible?(ancestor)
      end

      def inherited_from(ancestor, meths)
        return nil if meths.empty?

        links = meths.map { |meth| linker.link(meth, from: @from, label: code(meth.display_name)) }
        "- From #{linker.link(ancestor, from: @from)}: #{links.join(", ")}"
      end
    end
  end
end
