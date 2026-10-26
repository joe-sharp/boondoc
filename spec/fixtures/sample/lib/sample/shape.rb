# frozen_string_literal: true

module Sample
  # Base class for all shapes.
  #
  # @abstract Subclass and implement {#area}.
  class Shape
    include Comparable

    # @return [String] a label used in {#to_s}
    attr_accessor :name

    # @return [Integer] how many shapes have been built
    attr_reader :count

    # @param name [String] a label for the shape
    def initialize(name)
      @name = name
    end

    # Computes the area.
    #
    # @return [Float] the area in square units
    # @raise [NotImplementedError] unless overridden
    def area
      raise NotImplementedError
    end

    # Compares shapes by {#area}.
    #
    # @param other [Shape]
    # @return [Integer, nil]
    def <=>(other)
      area <=> other.area
    end

    # @return [Boolean] whether the shape has no area
    def empty?
      area.zero?
    end

    # Human readable description.
    #
    # @return [String]
    def to_s
      "#{name} (#{area})"
    end
    alias_method :inspect, :to_s

    protected

    # @return [Symbol]
    def kind
      :shape
    end

    private

    def helper; end
  end
end
