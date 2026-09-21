require_relative '../../lib/lownode'

module RBX
  class NodeWithEvent < LowNode
    def render(event:)
      <html>{event}</html>
    end
  end
end
