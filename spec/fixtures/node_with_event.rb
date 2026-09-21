# frozen_string_literal: true

require_relative '../../lib/lownode'

module Ruby
  class NodeWithEvent < LowNode
    def render(event:)
      event
    end
  end
end
