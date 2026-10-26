# frozen_string_literal: true

module Boondoc
  # Turns YARD-style references in markdown into relative links.
  #
  # Handles `{Foo#bar}`, `{Foo#bar custom text}`, `{https://example.com text}`,
  # `{file:GUIDE.md}`, and the include forms `{include:Foo}` and
  # `{include:file:path.md}`. Code blocks and code spans are left untouched.
  class Linker # rubocop:disable Metrics/ClassLength -- references and asset links resolved in one place
    REFERENCE = /(?<escape>\\)?\{(?<target>[^{}\s]+)(?:\s+(?<title>[^{}]+?))?\}/
    INCLUDE = /\{include:(?<file>file:)?(?<target>[^{}\s]+)\}/
    URL = %r{\A(?:[a-z][a-z0-9+.-]*://|mailto:)}i
    CONSTANT = /(?:::)?[A-Z]\w*(?:::[A-Z]\w*)*/
    CONSTANT_REFERENCE = /\A#{CONSTANT}(?:[#.].+)?\z/
    METHOD_REFERENCE = /\A[#.][^\s]/
    MAX_INCLUDE_DEPTH = 5

    # @param config [Config]
    # @param registry [Model::Registry]
    # @param filter [Filter]
    # @param path_map [PathMap]
    # @param stitcher [Stitcher]
    # @param assets [Assets] the files copied into the output, which image paths may name
    # @param reporter [Reporter]
    def initialize(config:, registry:, filter:, path_map:, stitcher:, reporter:, assets: Assets.new(config))
      @config = config
      @registry = registry
      @filter = filter
      @path_map = path_map
      @stitcher = stitcher
      @assets = assets
      @reporter = reporter
    end

    # Expands includes and resolves references in a piece of markdown, then points
    # paths to copied assets at their copies.
    #
    # @param text [String]
    # @param object [Model::CodeObject] where the text was written; references
    #   are looked up relative to it
    # @param from [String] the output file the text will appear in
    # @param assets [Boolean] whether to rewrite asset paths; false for stitched files,
    #   whose paths {Stitcher} has already rewritten
    # @return [String]
    def text(text, object:, from:, assets: true)
      text = Markdown.map_prose(expand_includes(text.to_s, object, 0)) do |prose|
        prose.gsub(REFERENCE) { reference(Regexp.last_match, object, from) }
      end
      return text unless assets

      Links.rewrite(text) { |target, embedded| asset_target(target, from, embedded) }
    end

    # @param object [Model::CodeObject]
    # @param from [String] the output file the link is written in
    # @param label [String, nil] link text; defaults to the object's path in a code span
    # @return [String] a markdown link, or just the label when the object is not rendered
    def link(object, from:, label: nil)
      label ||= "`#{object.path}`"
      @filter.visible?(object) ? "[#{label}](#{@path_map.href(object, from: from)})" : label
    end

    # Formats a type list, linking every constant that is documented.
    #
    # @param types [Array<String>, nil]
    # @param object [Model::CodeObject]
    # @param from [String]
    # @return [String, nil] such as `` `Array<`[`Foo`](Foo.md)`>`, `nil` ``
    def types(types, object:, from:)
      return nil if types.nil? || types.empty?

      types.map { |type| type_markup(type, object, from) }.join(', ')
    end

    private

    def expand_includes(text, object, depth)
      return text if depth > MAX_INCLUDE_DEPTH || !text.include?('{include:')

      Markdown.map_prose(text) do |prose|
        prose.gsub(INCLUDE) { included(Regexp.last_match, object, depth) }
      end
    end

    def included(match, object, depth)
      content = match[:file] ? read_file(match[:target]) : @registry.resolve(object, match[:target])&.docstring&.text
      unless content
        @reporter.warn("#{location(object)}: cannot include #{match[0]}")
        return match[0]
      end

      expand_includes(content.strip, object, depth + 1)
    end

    # Only files inside the project can be included.
    def read_file(path)
      full = File.expand_path(path, @config.root)
      File.read(full) if File.file?(full) && Containment.inside?(full, @config.root)
    end

    def reference(match, object, from)
      target = match[:target]
      title = match[:title]&.strip
      return match[0].delete_prefix('\\') if match[:escape]
      return match[0] if target.start_with?('include:')
      return "[#{title || target}](#{target})" if URL.match?(target)
      return file_reference(match, target.delete_prefix('file:'), title, from) if target.start_with?('file:')

      object_reference(match, title, object, from)
    end

    # A path in a docstring is relative to the output directory first, the way YARD's
    # `--asset` paths are, and to the project second. It is left as written unless it
    # names a file that is copied.
    def asset_target(target, from, embedded)
      path, suffix = target.split(/(?=[#?])/, 2)
      copied = @assets.copy_for(path, embedded: embedded)
      copied ? "#{@path_map.relative(copied, from)}#{suffix}" : target
    end

    def file_reference(match, name, title, from)
      file = @stitcher.find(name)
      return "[#{title || file.title}](#{@path_map.relative(file.output, from)})" if file

      @reporter.warn("cannot resolve #{match[0]}: #{name} is not one of the stitched files")
      match[0]
    end

    def object_reference(match, title, object, from)
      target = match[:target]
      found = @registry.resolve(object, target)
      return link(found, from: from, label: title || "`#{target}`") if found
      return match[0] unless reference_like?(target, object)

      return title || "`#{target}`" if core?(target)

      @reporter.warn("#{location(object)}: cannot resolve link to #{target}")
      match[0]
    end

    # Braces in prose are only reported as a broken reference when they look
    # like one; `{key: value}` and friends pass through silently. Either way
    # the original text is left exactly as written.
    def reference_like?(target, object)
      CONSTANT_REFERENCE.match?(target) || (!object.root? && METHOD_REFERENCE.match?(target))
    end

    # References to Ruby's own classes cannot be linked, but are not mistakes.
    def core?(target)
      CORE_CONSTANTS.include?(target.delete_prefix('::')[/\A[A-Z]\w*/])
    end

    def location(object)
      object.root? ? 'docs' : object.path
    end

    def type_markup(type, object, from)
      parts = []
      position = 0
      type.scan(CONSTANT) do
        match = Regexp.last_match
        found = @registry.resolve(object, match[0])
        next unless found && @filter.visible?(found)

        parts << code(type[position...match.begin(0)]) << link(found, from: from, label: code(match[0]))
        position = match.end(0)
      end
      (parts << code(type[position..])).compact.join
    end

    def code(text)
      "`#{text}`" unless text.empty?
    end
  end
end
