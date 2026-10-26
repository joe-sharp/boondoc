# frozen_string_literal: true

require 'pathname'

module Boondoc
  # A non-API file (README, changelog, guide) that is copied into the output.
  ExtraFile = Struct.new(:source, :output, :content, :readme, keyword_init: true) do
    # @return [String] the first top-level heading, or the file name
    def title
      content[/^#\s+(.+?)\s*#*\s*$/, 1] || File.basename(source, '.*')
    end
  end

  # Loads the extra files and keeps their relative links working after the move.
  class Stitcher
    MARKDOWN = /\.(?:md|markdown)\z/i

    # @return [Array<ExtraFile>] the README (if any) first, then the other files
    attr_reader :files

    # @param config [Config]
    # @param assets [Assets] the files that are copied into the output, which links follow to their copies
    def initialize(config, assets: Assets.new(config))
      @config = config
      @assets = assets
      readme = config.readme_file
      @files = config.extra_files.map { |source| load(source, "files/#{output_name(source)}") }
      @files.unshift(load(readme, config.index, readme: true)) if readme
    end

    # @return [ExtraFile, nil]
    def readme
      files.find(&:readme)
    end

    # Finds a stitched file by path, file name, or file name without extension.
    #
    # @param name [String]
    # @return [ExtraFile, nil]
    def find(name)
      files.find { |file| file.source == name } ||
        files.find { |file| [File.basename(file.source), File.basename(file.source, '.*')].include?(name) }
    end

    # Rewrites relative links and image paths so they still point at the same
    # thing from the file's new location in the output directory. A path to a
    # file that is copied into the output points at the copy.
    #
    # @param file [ExtraFile]
    # @return [String] the file's content with links adjusted
    def relocated_content(file)
      Links.rewrite(file.content) { |target, embedded| relocate(target, file, embedded: embedded) }
    end

    private

    def load(source, output, readme: false)
      content = File.read(File.expand_path(source, @config.root))
      content = "# #{File.basename(source)}\n\n```\n#{content.rstrip}\n```\n" unless MARKDOWN.match?(source)
      ExtraFile.new(source: source, output: output, content: content, readme: readme)
    end

    # Sources are relative to the project root; {Config#extra_files} rejects any outside it.
    def output_name(source)
      MARKDOWN.match?(source) ? source.sub(MARKDOWN, '.md') : "#{source}.md"
    end

    def relocate(target, file, embedded:)
      return target if Links::EXTERNAL.match?(target)

      path, suffix = target.split(/(?=[#?])/, 2)
      destination = destination_of(File.expand_path(path, File.dirname(source_path(file))), embedded)
      origin = Pathname.new(File.expand_path(file.output, @config.output_dir)).dirname
      "#{Pathname.new(destination).relative_path_from(origin)}#{suffix}"
    end

    def source_path(file)
      File.expand_path(file.source, @config.root)
    end

    # A link to another stitched file or to a copied asset follows it to its new
    # home; anything else keeps pointing at the original file in the project.
    def destination_of(absolute, embedded)
      stitched = files.find { |other| source_path(other) == absolute }
      output = stitched ? stitched.output : @assets.output_for(absolute, embedded: embedded)
      output ? File.expand_path(output, @config.output_dir) : absolute
    end
  end
end
