# frozen_string_literal: true

require_relative '../../lib/lownode'

module Ruby
  # Takes a different optional keyword in initialize and render.
  class KeywordNode < LowNode
    def initialize(limit: 5)
      super()
      @limit = limit
    end

    def render(suffix: '')
      "#{@limit}#{suffix}"
    end
  end
end
