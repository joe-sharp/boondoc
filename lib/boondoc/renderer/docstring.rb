# frozen_string_literal: true

module Boondoc
  module Renderer
    # Renders a docstring: callouts, body, then one section per kind of tag.
    class Docstring < Base
      CALLOUTS = { "deprecated" => "Deprecated", "abstract" => "Abstract", "note" => "Note",
                   "todo" => "Todo" }.freeze
      TYPED = { "yieldparam" => "Yield parameters", "yieldreturn" => "Yield returns",
                "return" => "Returns", "raise" => "Raises" }.freeze
      META = { "since" => "Since", "version" => "Version", "author" => "Author", "api" => "API" }.freeze
      HANDLED = (CALLOUTS.keys + TYPED.keys + META.keys +
                 %w[param option yield example see overload private attr attr_reader attr_writer]).freeze

      # @param context [Context]
      # @param object [Model::CodeObject] the object being documented
      # @param from [String] the output file being written
      def initialize(context, object, from)
        super(context)
        @object = object
        @from = from
      end

      # @param docstring [Model::Docstring]
      # @return [Array<String>] markdown blocks, in order
      def render(docstring)
        [
          callouts(docstring),
          text(docstring.text),
          parameters(docstring),
          yields(docstring),
          TYPED.map { |name, title| section(title, docstring.tags_named(name).map { |tag| typed(tag) }) },
          examples(docstring),
          see_also(docstring),
          meta(docstring),
          overloads(docstring)
        ].flatten.compact.reject(&:empty?)
      end

      private

      def text(text)
        linker.text(text, object: @object, from: @from).strip
      end

      def types(tag)
        linker.types(tag.types, object: @object, from: @from)
      end

      def callouts(docstring)
        docstring.tags.select { |tag| CALLOUTS.key?(tag.tag_name) }.map do |tag|
          body = text(tag.text)
          label = "**#{CALLOUTS[tag.tag_name]}#{":" unless body.empty?}** #{body}".strip
          label.lines.map { |line| "> #{line}".rstrip }.join("\n")
        end
      end

      def section(title, items)
        "**#{title}:**\n\n#{items.join("\n")}" unless items.empty?
      end

      def item(lead, description, indent: "")
        line = [lead, description].compact.reject(&:empty?).join(" — ")
        "#{indent}- #{line.gsub("\n", "\n#{indent}  ")}"
      end

      def typed(tag)
        types = types(tag)
        item([tag.name && code(tag.name), types && "(#{types})"].compact.join(" "), text(tag.text))
      end

      def parameters(docstring)
        params = docstring.tags_named("param")
        options = docstring.tags_named("option")
        items = params.flat_map { |tag| [typed(tag), *option_items(options, tag.name, "  ")] }
        [section("Parameters", items), *orphan_options(options, params.map(&:name))]
      end

      # Options whose hash is not itself documented with @param get their own section.
      def orphan_options(options, param_names)
        orphans = options.reject { |option| param_names.include?(option.name) }
        orphans.map(&:name).uniq.map do |name|
          section("Options (#{code(name)})", option_items(orphans, name, ""))
        end
      end

      def option_items(options, name, indent)
        options.select { |option| option.name == name }.map do |option|
          types = types(option)
          lead = [code(option.key), types && "(#{types})"].compact.join(" ")
          default = option.default && "(default: #{code(option.default)})"
          item(lead, [text(option.text), default].compact.reject(&:empty?).join(" "), indent: indent)
        end
      end

      def yields(docstring)
        items = docstring.tags_named("yield").map do |tag|
          names = tag.types&.map { |name| code(name) }&.join(", ")
          item(names && "(#{names})", text(tag.text))
        end
        section("Yields", items)
      end

      def examples(docstring)
        tags = docstring.tags_named("example")
        return nil if tags.empty?

        ["**Examples:**", *tags.flat_map { |tag| [("*#{tag.name}*" unless tag.name.to_s.empty?), fenced(tag.text)] }]
      end

      def fenced(source)
        source.match?(/\A\s*(?:```|~~~)/) ? source : ruby(source)
      end

      def see_also(docstring)
        section("See also", docstring.tags_named("see").map { |tag| item(see_link(tag.name.to_s), text(tag.text)) })
      end

      def see_link(name)
        return "<#{name}>" if Linker::URL.match?(name)

        found = registry.resolve(@object, name)
        found ? linker.link(found, from: @from, label: code(name)) : text(name)
      end

      def meta(docstring)
        known = META.flat_map { |name, title| docstring.tags_named(name).map { |tag| [title, tag] } }
        other = docstring.tags.reject { |tag| HANDLED.include?(tag.tag_name) }
          .map { |tag| [tag.tag_name.tr("_", " ").capitalize, tag] }
        items = (known + other).map { |title, tag| meta_item(title, tag) }
        items.join("\n") unless items.empty?
      end

      def meta_item(title, tag)
        types = types(tag)
        "- **#{title}:** #{[types && "(#{types})", text(tag.text)].compact.join(" ")}".rstrip
      end

      def overloads(docstring)
        docstring.tags_named("overload").flat_map do |tag|
          ["**Overload:**\n\n#{ruby("def #{tag.signature}")}", *render(tag.docstring)]
        end
      end
    end
  end
end
