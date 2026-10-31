# frozen_string_literal: true

module Boondoc
  # Runs the whole pipeline: parse, resolve, render, write.
  #
  # @example
  #   Boondoc::Generator.new(Boondoc::Config.new(output: 'docs')).run
  class Generator
    # What a run produced.
    Result = Struct.new(:pages, :assets, :removed, :warnings, keyword_init: true)

    # @return [Model::Registry] the registry built by the last {#run}
    attr_reader :registry

    # @param config [Config]
    # @param reporter [Reporter]
    def initialize(config, reporter: Reporter.new(quiet: config.quiet))
      @config = config
      @reporter = reporter
    end

    # @return [Result]
    # @raise [Error] when no source files match, the output directory is unsafe,
    #   a file would be overwritten, or `strict` is set and there were warnings
    def run
      report_config
      files = @config.source_files
      raise Error, "no Ruby files matched #{Array(@config.sources).join(", ")}" if files.empty?

      parse(files)
      pages = render
      removed = Writer.new(@config.output_dir, @reporter, force: @config.force).write(pages, assets: @assets)
      finish(pages, @assets, removed)
    end

    # Builds every page without writing anything.
    #
    # @return [Hash{String => String}] page content keyed by path relative to the output directory
    def render
      context = build_context
      pages = pages_for(context)
      @assets = context.assets.files # linked assets are found while the pages render
      pages
    end

    # Parses the given files into a fresh registry.
    #
    # @param files [Array<String>] paths relative to the project root
    # @return [Model::Registry]
    def parse(files)
      @registry = Model::Registry.new
      parser = Frontend::PrismParser.new(@registry, @reporter)
      files.each { |file| parser.parse_file(File.expand_path(file, @config.root), label: file) }
      expand_directives(files)
      References.new(@registry).expand
      @registry
    end

    private

    def report_config
      @config.output_dir # refuse an unsafe output directory before doing any work
      @config.yardopts_notes.each { |note| @reporter.info(note) }
      @config.outside_sources.each do |path|
        @reporter.warn("skipping #{path}: it is outside the project (#{@config.root})")
      end
    end

    def expand_directives(files)
      if @config.yard_macros
        merge_yard(files & @registry.directive_files)
      elsif @registry.directive_sites.any?
        sites = @registry.directive_sites
        @reporter.warn(
          "#{sites.size} comment(s) use YARD directives (@!macro, @!method, ...), which boondoc " \
          "does not expand on its own; rerun with --yard-macros. First: #{sites.first(3).join(", ")}"
        )
      end
    end

    def merge_yard(yard_files)
      added = yard_files.empty? ? 0 : YardBridge.new(@registry, @reporter).merge(yard_files, root: @config.root)
      @reporter.info("yard: added #{added} object(s) from macros and directives")
      return unless yard_files.empty?

      @reporter.warn(
        "yard: no YARD macros or directives were found; disable yard_macros " \
        "(--yard-macros) for this project"
      )
    end

    def pages_for(context)
      index = Renderer::Index.new(context)
      pages = { @config.index => index.render }
      context.stitcher.files.reject(&:readme).each { |file| pages[file.output] = index.render_file(file) }
      namespace_pages(context).each { |namespace, page| pages[context.path_map.file_for(namespace)] = page.render }
      pages
    end

    def build_context
      Context.new(config: @config, registry: @registry, reporter: @reporter)
    end

    def namespace_pages(context)
      namespaces = @registry.grep(Model::NamespaceObject).select { |namespace| context.filter.visible?(namespace) }
      namespaces.to_h { |namespace| [namespace, Renderer::NamespacePage.new(context, namespace)] }
        .select { |_, page| page.content? }
    end

    def finish(pages, assets, removed)
      warnings = @reporter.warnings
      @reporter.info(
        "boondoc: wrote #{pages.size} file(s) and #{assets.size} asset(s) to #{@config.output}" \
        "#{", removed #{removed.size} stale" if removed.any?}" \
        "#{", #{warnings.size} warning(s)" if warnings.any?}"
      )
      raise Error, "#{warnings.size} warning(s) in strict mode" if @config.strict && warnings.any?

      Result.new(pages: pages.keys.sort, assets: assets.keys.sort, removed: removed, warnings: warnings)
    end
  end
end
