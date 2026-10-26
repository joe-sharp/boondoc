# frozen_string_literal: true

module Sample
  # A circle.
  #
  # @example Build one and measure it
  #   circle = Sample::Circle.new(2)
  #   circle.area #=> 12.566370614359172
  #
  # @see Shape
  # @see https://en.wikipedia.org/wiki/Circle Circle on Wikipedia
  class Circle < Shape
    # Circles per turn.
    TAU = Math::PI * 2

    class << self
      # Builds a circle from its diameter.
      #
      # @param diameter [Numeric]
      # @param options [Hash] extra settings
      # @option options [String] :name ("circle") label for the shape
      # @option options [Boolean] :strict reject non-positive sizes
      # @return [Circle]
      # @raise [Sample::Error] when the diameter is not positive and strict is set
      def from_diameter(diameter, options = {})
        new(diameter / 2.0, **options)
      end
    end

    # @return [Numeric]
    attr_reader :radius

    # @param radius [Numeric] must be positive
    # @param name [String]
    def initialize(radius, name: 'circle')
      super(name)
      @radius = radius
    end

    # (see Shape#area)
    def area
      Math::PI * (radius**2)
    end

    # Scales the circle.
    #
    # @overload scale(factor)
    #   @param factor [Numeric] multiplier for the radius
    #   @return [Circle] a new, scaled circle
    # @overload scale(factor, &block)
    #   @yield [radius] lets the caller adjust the scaled radius
    #   @yieldparam radius [Numeric] the scaled radius
    #   @yieldreturn [Numeric] the radius to use
    #   @return [Circle]
    # @deprecated Use {Util.scale} instead.
    def scale(factor)
      radius = self.radius * factor
      radius = yield(radius) if block_given?
      self.class.new(radius, name: name)
    end

    # @note This is approximate for very large radii.
    # @return [Array<Point>, nil] points on the edge, or nil when {#empty?}
    # @todo Support a custom step.
    def points; end

    # A broken link to {Missing::Thing} for the warning test.
    def self.unit
      new(1)
    end

    private_class_method def self.hidden; end
  end
end
