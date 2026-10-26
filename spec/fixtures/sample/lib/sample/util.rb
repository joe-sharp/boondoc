# frozen_string_literal: true

module Sample
  # Stateless helpers.
  module Util
    module_function

    # Scales a shape.
    #
    # @param shape [Circle] the shape to scale
    # @param factor [Numeric]
    # @return [Circle]
    def scale(shape, factor)
      shape.scale(factor)
    end

    # @param value [Numeric, #to_f]
    # @return [Float]
    # @api public
    # @custom_tag some text
    def clamp(value, min: 0, max: 1)
      value.to_f.clamp(min, max)
    end
  end
end
