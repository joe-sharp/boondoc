# frozen_string_literal: true

require 'pathname'

module Boondoc
  # The files that are copied into the output directory next to the pages: images, video, PDFs,
  # and anything else a page links to or embeds.
  #
  # Two kinds are copied. The ones named by the `assets` option are always copied. Each entry is a
  # file, a directory (everything under it), or a glob, optionally followed by `:DIR` to copy into
  # that directory of the output instead of keeping the project path. Hidden files, symlinks that
  # leave the project, and anything in the output directory are skipped. With `copy_linked_assets`
  # the files that pages embed are copied too, as they are found while the pages are rendered, so
  # {#files} is only complete once rendering has finished.
  class Assets
    # @param config [Config]
    # @raise [Error] when a named file is outside the project, or two files would be copied to the same path
    def initialize(config)
      @config = config
      @named = Array(config.assets).each_with_object({}) { |entry, map| add(map, entry) }
      @by_source = @named.invert
      @linked = {}
    end

    # Where a file will be in the output directory, when it is copied there.
    #
    # @param absolute [String] absolute path of a file in the project
    # @param embedded [Boolean] whether the page embeds the file, as an image does
    # @return [String, nil] the path relative to the output directory, or nil when the file is not copied
    def output_for(absolute, embedded: false)
      @by_source[absolute] || (link(absolute) if embedded && @config.copy_linked_assets)
    end

    # Finds the copy of a path written in a page. A path is first read relative to the output
    # directory, as YARD's `--asset` paths are, and then relative to the project.
    #
    # @param path [String] a path without any fragment or query
    # @param embedded [Boolean] whether the page embeds the file rather than linking to it
    # @return [String, nil] the path relative to the output directory, or nil when nothing is copied
    def copy_for(path, embedded: false)
      output = Pathname.new(path).cleanpath.to_s
      return output if @named.key?(output)

      output_for(File.expand_path(path, @config.root), embedded: embedded)
    end

    # @return [Hash{String => String}] absolute source paths, keyed by the path relative to
    #   the output directory that each is copied to
    def files
      @named.merge(@linked)
    end

    private

    def add(map, entry)
      from, directory = entry.split(':', 2)
      Dir.glob(from, base: @config.root).each do |match|
        sources(match).each do |source, within|
          output = directory ? output_path(directory, within) : source
          absolute = File.expand_path(source, @config.root)
          clash = map.fetch(output, absolute) != absolute
          raise Error, "#{output} would be copied from both #{map[output]} and #{absolute}" if clash

          map[output] = absolute
        end
      end
    end

    # @return [Array<Array(String, String)>] each file under a match, as its path in the project and
    #   its path relative to the match, which a `:DIR` destination keeps
    def sources(match)
      full = File.expand_path(match, @config.root)
      raise Error, "#{match} is outside the project (#{@config.root})" unless Containment.inside?(full, @config.root)
      return [[relative(full), File.basename(full)]] if File.file?(full)

      Dir.glob('**/*', base: full).select { |path| named_file?(File.join(full, path)) }
         .map { |path| [relative(File.join(full, path)), path] }
    end

    def named_file?(full)
      inside = full.delete_prefix(File.join(@config.root, ''))
      File.file?(full) && inside.split('/').none? { |part| part.start_with?('.') } &&
        Containment.inside?(full, @config.root) && !full.start_with?(File.join(@config.output_dir, ''))
    end

    def output_path(directory, within)
      path = Pathname.new(File.join(directory, within)).cleanpath.to_s
      raise Error, "asset destination #{directory} is outside the output directory" if path.start_with?('..', '/')

      path
    end

    def relative(full)
      Pathname.new(full).relative_path_from(Pathname.new(@config.root)).to_s
    end

    # Remembers an embedded file that is worth copying and returns where it goes.
    def link(absolute)
      root = File.join(@config.root, '')
      return nil unless absolute.start_with?(root) && copyable?(absolute)

      output = absolute.delete_prefix(root)
      @linked[output] = absolute
      output
    end

    def copyable?(absolute)
      File.file?(absolute) && !Stitcher::MARKDOWN.match?(absolute) &&
        !absolute.start_with?(File.join(@config.output_dir, '')) && Containment.inside?(absolute, @config.root)
    end
  end
end
