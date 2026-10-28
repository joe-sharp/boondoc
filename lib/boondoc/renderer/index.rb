# frozen_string_literal: true

module Boondoc
  module Renderer
    # Renders the index page (README plus tables of contents) and stitched files.
    class Index < Base
      # @return [String] the index page
      def render
        from = context.config.index
        readme = context.stitcher.readme
        intro = readme ? file_body(readme) : "# #{context.config.title}"
        document([intro, api(from), files(from)])
      end

      # @param file [ExtraFile]
      # @return [String] a stitched file with its links and references resolved
      def render_file(file)
        document([file_body(file)])
      end

      private

      def file_body(file)
        linker.text(context.stitcher.relocated_content(file), object: registry.root, from: file.output, assets: false)
      end

      def api(from)
        lines = tree(registry.root, from, 0)
        top = NamespacePage.new(context, registry.root)
        lines << "- [Top level](#{path_map.relative(PathMap::TOP_LEVEL, from)})" if top.content?
        ["## API reference", lines.join("\n")] unless lines.empty?
      end

      def tree(namespace, from, depth)
        namespace.namespaces.select { |child| filter.visible?(child) }.flat_map do |child|
          entry = bullet(linker.link(child, from: from), summary(child, from))
          ["#{"  " * depth}#{entry}", *tree(child, from, depth + 1)]
        end
      end

      def files(from)
        extras = context.stitcher.files.reject(&:readme)
        return nil if extras.empty?

        ["## Files", extras.map { |file| "- [#{file.title}](#{path_map.relative(file.output, from)})" }.join("\n")]
      end
    end
  end
end
