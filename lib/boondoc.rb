# frozen_string_literal: true

require "prism"

require_relative "boondoc/version"

# Markdown-only API documentation for Ruby.
#
# Source is parsed with Prism into a {Boondoc::Model::Registry}, and every class
# and module is rendered to its own markdown file. See {Boondoc::Generator} for
# the pipeline and {Boondoc::CLI} for the command line.
module Boondoc
  # Raised for any failure Boondoc reports to the user.
  class Error < StandardError; end
end

require_relative "boondoc/reporter"
require_relative "boondoc/containment"
require_relative "boondoc/yardopts"
require_relative "boondoc/config"
require_relative "boondoc/markdown"
require_relative "boondoc/model/docstring"
require_relative "boondoc/model/code_object"
require_relative "boondoc/model/registry"
require_relative "boondoc/type_parser"
require_relative "boondoc/docstring_parser"
require_relative "boondoc/frontend/comments"
require_relative "boondoc/frontend/visitor"
require_relative "boondoc/frontend/prism_parser"
require_relative "boondoc/yard_bridge"
require_relative "boondoc/references"
require_relative "boondoc/filter"
require_relative "boondoc/path_map"
require_relative "boondoc/links"
require_relative "boondoc/assets"
require_relative "boondoc/stitcher"
require_relative "boondoc/core_constants"
require_relative "boondoc/linker"
require_relative "boondoc/context"
require_relative "boondoc/renderer/base"
require_relative "boondoc/renderer/docstring"
require_relative "boondoc/renderer/method_section"
require_relative "boondoc/renderer/namespace_page"
require_relative "boondoc/renderer/index"
require_relative "boondoc/writer"
require_relative "boondoc/generator"
require_relative "boondoc/preview"
require_relative "boondoc/cli"
