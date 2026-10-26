# frozen_string_literal: true

module Boondoc
  # Decides which objects appear in the output.
  class Filter
    # @param config [Config]
    def initialize(config)
      @config = config
    end

    # An object is visible when it and every enclosing namespace pass the
    # visibility options (`--private`, `--protected`).
    #
    # @param object [Model::CodeObject]
    # @return [Boolean]
    def visible?(object)
      return true if object.root?

      allowed?(object) && visible?(object.namespace)
    end

    private

    def allowed?(object)
      return false if object.private_api? && !@config.private

      case object.visibility
      when :private   then @config.private
      when :protected then @config.private || @config.protected
      else true
      end
    end
  end
end
