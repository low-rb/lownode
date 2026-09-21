require_relative '../../lib/lownode'

module RBX
  class ParentNode < LowNode
    def render
      <html><{ ChildNode }></html>
    end
  end
end
