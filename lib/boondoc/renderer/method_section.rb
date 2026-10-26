# frozen_string_literal: true

module Boondoc
  module Renderer
    # Renders the detail section for one method or one attribute.
    class MethodSection < Base
      # @param context [Context]
      # @param from [String] the output file being written
      def initialize(context, from)
        super(context)
        @from = from
      end

      # @param meth [Model::MethodObject]
      # @return [Array<String>] markdown blocks
      def render(meth)
        [
          heading(meth.display_name, [meth]),
          ruby(signature(meth)),
          facts(meth),
          *Docstring.new(context, meth, @from).render(meth.docstring)
        ]
      end

      # Renders a reader and/or writer as a single attribute entry.
      #
      # @param accessors [Array<Model::MethodObject>] the reader, the writer, or both
      # @return [Array<String>] markdown blocks
      def render_attribute(accessors)
        reader = accessors.find { |meth| meth.attribute == :reader }
        writer = accessors.find { |meth| meth.attribute == :writer }
        primary = reader || writer
        name = primary.name.delete_suffix('=')
        macro = reader && writer ? 'attr_accessor' : "attr_#{primary.attribute}"
        [
          heading("#{primary.separator}#{name}", accessors),
          ruby("#{macro} :#{name}"),
          facts(primary),
          *Docstring.new(context, primary, @from).render(documented(accessors).docstring)
        ]
      end

      # @param meth [Model::MethodObject]
      # @return [String] the method as it would be defined, such as `def self.build(name)`
      def signature(meth)
        params = meth.parameters ? "(#{meth.parameters})" : ''
        "def #{'self.' if meth.scope == :class}#{meth.name}#{params}"
      end

      private

      def documented(accessors)
        accessors.find { |meth| !meth.docstring.empty? } || accessors.first
      end

      # Explicit anchors, because heading slugs cannot tell `foo`, `foo?`, and `foo!` apart.
      def heading(title, objects)
        anchors = objects.map { |object| %(<a id="#{path_map.anchor_for(object)}"></a>) }.join
        "### #{anchors}#{code(title)}"
      end

      def facts(meth)
        lines = []
        lines << "- **Visibility:** #{meth.visibility}" unless meth.visibility == :public
        lines << "- **Alias for:** #{alias_link(meth)}" if meth.alias_for
        aliases = aliases_of(meth)
        lines << "- **Also known as:** #{aliases.join(', ')}" unless aliases.empty?
        lines.join("\n") unless lines.empty?
      end

      def alias_link(meth)
        original = registry[Model::MethodObject.path_for(meth.namespace, meth.scope, meth.alias_for)]
        label = code("#{meth.separator}#{meth.alias_for}")
        original ? linker.link(original, from: @from, label: label) : label
      end

      def aliases_of(meth)
        aliases = context.aliases(meth.namespace, meth.scope).fetch(meth.name, [])
        aliases.select { |other| filter.visible?(other) }
               .map { |other| linker.link(other, from: @from, label: code(other.display_name)) }
      end
    end
  end
end
