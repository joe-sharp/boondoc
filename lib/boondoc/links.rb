# frozen_string_literal: true

module Boondoc
  # Finds the paths in markdown links, images and HTML attributes so they can be rewritten.
  #
  # Each path is passed on together with whether it is embedded in the page, as an image, video,
  # audio, `<source>` or `srcset`, or only linked to. Code blocks and code spans are left alone.
  module Links
    # Targets that are not paths in the project: URLs, anchors, absolute paths, and `{references}`.
    EXTERNAL = %r{\A(?:[a-z][a-z0-9+.-]*:|[#/\{])}i
    INLINE = /(?<lead>\]\(\s*<?)(?<target>[^)\s>]+)/ # [text](target) and ![alt](target)
    DEFINITION = /^(?<lead> {0,3}\[(?<label>[^\]]+)\]:\s+<?)(?<target>[^\s>]+)/ # [label]: target
    ATTRIBUTE = /(?<lead>\b(?<name>src|href|poster|data)=["'])(?<target>[^"']+)/ # <img src="target">
    SRCSET = /(?<lead>\bsrcset=["'])(?<value>[^"']+)/ # <source srcset="a.png 1x, b.png 2x">
    SRCSET_ENTRY = /(?<url>[^\s,]+)(?<descriptor>\s+\d[\d.]*[wx])?/
    IMAGE_REFERENCE = /!\[(?<alt>[^\]]*)\]\[(?<label>[^\]]*)\]/
    EMBEDDING_ATTRIBUTES = %w[src poster data].freeze
    IMAGE_OPENING = /!\[(?:[^\[\]]|\[[^\[\]]*\])*\z/ # an image whose alt text is still open

    module_function

    # @param content [String] markdown
    # @yieldparam target [String] a path as written, with any fragment or query still attached
    # @yieldparam embedded [Boolean] whether the page embeds the file rather than linking to it
    # @yieldreturn [String] the path to write in its place
    # @return [String] the content with every path replaced by the block's result
    def rewrite(content, &)
      labels = embedded_labels(content)
      Markdown.map_prose(content) { |prose| rewrite_prose(prose, labels, &) }
    end

    # @api private
    def rewrite_prose(prose, labels, &)
      prose = rewrite_links(prose, labels, &)
      prose = prose.gsub(ATTRIBUTE) do
        replace(Regexp.last_match, EMBEDDING_ATTRIBUTES.include?(Regexp.last_match[:name]), &)
      end
      prose.gsub(SRCSET) { "#{Regexp.last_match[:lead]}#{rewrite_srcset(Regexp.last_match[:value], &)}" }
    end

    # @api private
    def rewrite_links(prose, labels, &)
      inline = prose.gsub(INLINE) { replace(Regexp.last_match, embedded_inline?(prose, Regexp.last_match), &) }
      inline.gsub(DEFINITION) { replace(Regexp.last_match, labels.include?(Regexp.last_match[:label].downcase), &) }
    end

    # @api private
    def replace(match, embedded)
      return match[0] if EXTERNAL.match?(match[:target])

      "#{match[:lead]}#{yield(match[:target], embedded)}"
    end

    # @api private
    def rewrite_srcset(value)
      value.gsub(SRCSET_ENTRY) do
        url = Regexp.last_match[:url]
        "#{EXTERNAL.match?(url) ? url : yield(url, true)}#{Regexp.last_match[:descriptor]}"
      end
    end

    # The labels that an `![alt][label]` image refers to.
    #
    # @api private
    def embedded_labels(content)
      content.scan(IMAGE_REFERENCE).map { |alt, label| (label.empty? ? alt : label).downcase }
    end

    # Whether the link at `match` is the text of an image, `![...](...)`, rather than a plain link.
    # The text before it, on the same line, must open an image and close only nested brackets.
    #
    # @api private
    def embedded_inline?(text, match)
      line = (text.rindex("\n", match.begin(:lead)) || -1) + 1
      IMAGE_OPENING.match?(text[line...match.begin(:lead)])
    end
  end
end
