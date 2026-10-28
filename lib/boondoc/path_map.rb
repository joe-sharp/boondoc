# frozen_string_literal: true

require "pathname"

module Boondoc
  # Maps objects to output files and anchors, and computes relative links.
  class PathMap
    TOP_LEVEL = "top-level.md"

    # @param config [Config]
    # @param registry [Model::Registry] consulted for classes and modules whose
    #   names differ only by case
    def initialize(config, registry)
      @config = config
      @registry = registry
      @relative = {}
    end

    # @param object [Model::CodeObject]
    # @return [String] output file, relative to the output directory. Classes and
    #   modules whose names differ only by case get their kind appended, such as
    #   `CLI.class.md` and `Cli.module.md`, so that the files stay apart on
    #   case-insensitive filesystems.
    def file_for(object)
      namespace = object.is_a?(Model::NamespaceObject) ? object : object.namespace
      namespace.root? ? TOP_LEVEL : (@files ||= {}.compare_by_identity)[namespace] ||= "#{directory(namespace)}.md"
    end

    # @param object [Model::CodeObject]
    # @return [String, nil] the anchor inside its file; nil for namespaces
    def anchor_for(object)
      case object
      when Model::MethodObject then "method-#{(object.scope == :class) ? "c" : "i"}-#{escape(object.name)}"
      when Model::ConstantObject then "constant-#{escape(object.name)}"
      end
    end

    # @param object [Model::CodeObject]
    # @param from [String] the output file the link is written in
    # @return [String] a relative link to the object
    def href(object, from:)
      anchor = anchor_for(object)
      file = file_for(object)
      return "##{anchor}" if anchor && file == from

      [relative(file, from), anchor].compact.join("#")
    end

    # @param file [String] output file to link to
    # @param from [String] output file the link is written in
    # @return [String] frozen; each distinct link is worked out once, because
    #   the same few targets are linked many times in a run
    def relative(file, from)
      @relative[[file, from]] ||= encode(Pathname.new(file).relative_path_from(Pathname.new(from).dirname).to_s).freeze
    end

    # @param source [String] a path relative to the project root
    # @param from [String] output file the link is written in
    # @return [String] a relative link from the output file to a project file
    def source_href(source, from:)
      target = Pathname.new(File.expand_path(source, @config.root))
      origin = Pathname.new(File.expand_path(from, @config.output_dir)).dirname
      encode(target.relative_path_from(origin).to_s)
    end

    private

    def directory(namespace)
      parts = []
      while namespace && !namespace.root?
        parts.unshift(segments[namespace])
        namespace = namespace.namespace
      end
      parts.join("/")
    end

    # The file or directory name of every class and module, worked out once
    # because nothing changes the registry while pages are rendered.
    def segments
      @segments ||= {}.compare_by_identity.tap { |names| name_children(@registry.root, names) }
    end

    def name_children(parent, names)
      parent.namespaces.group_by { |child| child.name.downcase }.each_value do |group|
        group.each { |child| names[child] = child.name } if group.one?
        disambiguate(group, names) if group.size > 1
      end
      parent.namespaces.each { |child| name_children(child, names) }
    end

    # Appends the kind, and a number when two of the same kind still collide.
    def disambiguate(group, names)
      seen = Hash.new(0)
      group.each do |child|
        count = (seen[child.kind] += 1)
        names[child] = ["#{child.name}.#{child.kind}", (count if count > 1)].compact.join("-")
      end
    end

    def escape(name)
      name.gsub(/[^A-Za-z0-9_]/) { |char| format("-%02X", char.ord) }
    end

    def encode(path)
      path.gsub(" ", "%20")
    end
  end
end
