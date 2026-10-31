# frozen_string_literal: true

module Boondoc
  # Everything the renderers need to produce a page.
  class Context
    attr_reader :config, :registry, :reporter, :filter, :path_map, :assets, :stitcher, :linker

    # @param config [Config]
    # @param registry [Model::Registry]
    # @param reporter [Reporter]
    def initialize(config:, registry:, reporter:)
      @config = config
      @registry = registry
      @reporter = reporter
      @filter = Filter.new(config)
      @path_map = PathMap.new(config, registry)
      @assets = Assets.new(config)
      @stitcher = Stitcher.new(config, assets: assets)
      @linker = Linker.new(
        config: config,
        registry: registry,
        filter: filter,
        path_map: path_map,
        stitcher: stitcher,
        assets: assets,
        reporter: reporter
      )
      @meths = {}
      @aliases = {}
    end

    # The methods of a namespace in one scope, sorted once per run.
    #
    # Nothing changes the registry while pages are rendered, so the list can be
    # kept for the lifetime of the context. Keeping it here rather than in the
    # model matters because the parser changes `children` directly.
    #
    # @param namespace [Model::NamespaceObject]
    # @param scope [Symbol] `:instance` or `:class`
    # @return [Array<Model::MethodObject>] see {Model::NamespaceObject#meths}
    def meths(namespace, scope)
      @meths[[namespace, scope]] ||= namespace.meths(scope).freeze
    end

    # The aliases of the methods of a namespace, found without scanning every
    # method for each one.
    #
    # @param namespace [Model::NamespaceObject]
    # @param scope [Symbol] `:instance` or `:class`
    # @return [Hash{String => Array<Model::MethodObject>}] aliases keyed by the name they alias
    def aliases(namespace, scope)
      @aliases[[namespace, scope]] ||= meths(namespace, scope).select(&:alias_for).group_by(&:alias_for).freeze
    end
  end
end
