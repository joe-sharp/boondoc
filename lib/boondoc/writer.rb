# frozen_string_literal: true

require "fileutils"

module Boondoc
  # Writes generated pages and removes pages left over from earlier runs.
  #
  # A manifest in the output directory records what Boondoc wrote, so only its
  # own files are ever deleted or silently overwritten. A page whose content has
  # not changed is not written again.
  class Writer
    MANIFEST = ".boondoc-manifest"

    # @param output_dir [String] absolute path of the output directory
    # @param reporter [Reporter]
    # @param force [Boolean] overwrite files that Boondoc did not generate
    def initialize(output_dir, reporter, force: false)
      @output_dir = output_dir
      @reporter = reporter
      @force = force
    end

    # @param pages [Hash{String => String}] content keyed by path relative to the output directory
    # @param assets [Hash{String => String}] absolute source paths of files to copy, keyed by
    #   the path relative to the output directory
    # @return [Array<String>] stale files that were removed
    # @raise [Error] when a page would overwrite a file Boondoc did not generate,
    #   or would be written outside the output directory or through a symlink
    def write(pages, assets: {})
      outputs = pages.keys + assets.keys
      previous = manifest
      check(outputs, previous)
      stale = remove_stale(previous - outputs)
      pages.each { |path, content| write_page(path, content) }
      assets.each { |path, source| copy_asset(path, source) }
      write_file(File.join(@output_dir, MANIFEST), "#{outputs.sort.join("\n")}\n")
      stale
    end

    private

    def manifest
      path = File.join(@output_dir, MANIFEST)
      return [] unless File.file?(path)

      File.readlines(path, chomp: true).reject(&:empty?)
    end

    def check(paths, previous)
      paths.each { |path| check_destination(path) }
      check_duplicates(paths)
      check_conflicts(paths, previous)
      warn_case_collisions(paths)
    end

    # A page and an asset cannot be written to the same path.
    def check_duplicates(paths)
      duplicate = paths.tally.find { |_, count| count > 1 }&.first
      raise Error, "a page and an asset would both be written to #{duplicate}" if duplicate
    end

    # Stale files go first: on a case-insensitive filesystem a file renamed only by case is the same
    # file, and removing it afterwards would delete the file just written.
    def remove_stale(paths)
      stale = paths.select { |path| removable?(path) }
      stale.each { |path| remove(path) }
      stale
    end

    def check_destination(path)
      problem = unsafe(path)
      raise Error, "refusing to write #{path}: #{problem}" if problem
    end

    # The manifest is part of the output directory and may have been edited,
    # so stale entries get the same checks as pages before anything is deleted.
    def removable?(path)
      problem = unsafe(path)
      @reporter.warn("not removing stale #{path}: #{problem}") if problem
      problem.nil?
    end

    # @return [String, nil] why writing or deleting `path` would touch a file
    #   outside the output directory
    def unsafe(path)
      full = File.expand_path(path, @output_dir)
      return "it is outside #{@output_dir}" unless full.start_with?(File.join(@output_dir, ""))

      # The symlink check below resolves `..` by name, but the file system follows a symlink first.
      return "it contains `..`" if path.split("/").include?("..")

      link = Containment.symlink_between(full, @output_dir)
      "#{link} is a symlink" if link
    end

    def check_conflicts(paths, previous)
      return if @force

      conflicts = paths.select do |path|
        File.exist?(File.join(@output_dir, path)) &&
          !previous.include?(path) && !same_file_as_earlier_page?(path, previous)
      end
      return if conflicts.empty?

      raise Error, "refusing to overwrite #{conflicts.size} file(s) that boondoc did not generate " \
                   "(#{conflicts.first(5).join(", ")}#{", ..." if conflicts.size > 5}). " \
                   "Use --force to overwrite, or choose another --output directory."
    end

    # True when a case-insensitive filesystem maps the path onto a page Boondoc wrote before.
    def same_file_as_earlier_page?(path, previous)
      previous.any? do |known|
        known.casecmp?(path) && File.identical?(File.join(@output_dir, known), File.join(@output_dir, path))
      end
    end

    # Pages for classes and modules never get here, because PathMap tells them apart. What is left
    # are stitched files, assets and the index, whose names come from the project.
    def warn_case_collisions(paths)
      paths.group_by(&:downcase).each_value do |group|
        next if group.size == 1

        @reporter.warn("#{group.sort.join(" and ")} differ only by case and will collide on case-insensitive " \
                       "filesystems; rename one of them")
      end
    end

    def write_page(path, content)
      full = File.join(@output_dir, path)
      FileUtils.mkdir_p(File.dirname(full))
      write_file(full, content)
    end

    # Leaves a file that already holds this content alone, so its modification
    # time only changes when the page does. This runs after every destination
    # has passed {#check}, so it never reads through a symlink.
    def write_file(full, content)
      return if File.file?(full) && File.size(full) == content.bytesize && File.binread(full) == content.b

      File.write(full, content)
    end

    # Copies a file byte for byte. A copy that already matches is left alone, so
    # its modification time only changes when the file does.
    def copy_asset(path, source)
      full = File.join(@output_dir, path)
      FileUtils.mkdir_p(File.dirname(full))
      return if File.file?(full) && FileUtils.compare_file(source, full)

      FileUtils.cp(source, full)
    end

    def remove(path)
      full = File.join(@output_dir, path)
      FileUtils.rm_f(full)
      directory = File.dirname(full)
      while directory.start_with?("#{@output_dir}/") && Dir.empty?(directory)
        Dir.rmdir(directory)
        directory = File.dirname(directory)
      end
    end
  end
end
