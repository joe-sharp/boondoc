# frozen_string_literal: true

require_relative 'sample/shape'
require_relative 'sample/circle'
require_relative 'sample/util'

# A tiny geometry library used to exercise boondoc.
#
# Start with {Sample::Circle}, or read the {file:guides/intro.md guide}.
# A hash literal like {radius: 2} is left alone.
#
#     # indented code keeps its braces: {Sample::Circle}
#     Sample::Circle.new(2)
#
# @since 0.1.0
module Sample
  # The current version.
  VERSION = '1.2.3'

  # Raised when a shape cannot be built.
  class Error < StandardError; end

  # A 2D point.
  Point = Struct.new(:x, :y) do
    # @return [Float] distance from the origin
    def magnitude
      Math.sqrt((x**2) + (y**2))
    end
  end

  # @private
  class Internal
    def secret; end
  end
end

# Formats a number for display.
#
# @param number [Numeric]
# @return [String]
def format_number(number)
  number.to_s
end
