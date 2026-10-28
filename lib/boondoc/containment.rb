# frozen_string_literal: true

module Boondoc
  # Checks that a path stays inside a directory once symlinks are followed.
  #
  # The project being documented is not trusted to point Boondoc at files
  # elsewhere on the machine, through `../`, absolute paths, or symlinks.
  module Containment
    module_function

    # @param path [String] an existing file or directory
    # @param directory [String]
    # @return [Boolean] true when the real path of `path` is `directory` or inside it
    def inside?(path, directory)
      real = File.realpath(path)
      base = File.realpath(directory)
      real == base || real.start_with?(File.join(base, ""))
    rescue SystemCallError
      false
    end

    # Finds a symlink on the way from `directory` down to `path`.
    #
    # Only the names are looked at (`..` is resolved first), so this also works
    # for a path that does not exist yet. `directory` itself is not checked.
    #
    # @param path [String] a path below `directory`, which need not exist
    # @param directory [String]
    # @return [String, nil] the first component that is a symlink, or nil when
    #   there is none or `path` is not below `directory`
    def symlink_between(path, directory)
      base = File.join(File.expand_path(directory), "")
      full = File.expand_path(path)
      return nil unless full.start_with?(base)

      parts = full.delete_prefix(base).split("/")
      parts.each_index.map { |count| File.join(base, *parts.first(count + 1)) }.find { |step| File.symlink?(step) }
    end
  end
end
