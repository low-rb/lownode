require_relative '../../lib/lownode'

module RBX
  class ChildNode < LowNode
    def render
      <p>{"I'm a child"}</p>
    end
  end
end
