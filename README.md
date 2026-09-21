<a href="https://rubygems.org/gems/lownode" title="Install gem"><img src="https://badge.fury.io/rb/lownode.svg" alt="Gem version" height="18"></a>

# LowNode

Low Nodes are the flexible building blocks of your application. They can respond to a route request, or they can be called by another node. They can render a return value, or they can create an event. They are designed to be specific enough to observe events and return values, but generic enough to be split up to represent a complex application with its own patterns and structure.

Nodes can render HTML/JSON directly from the Ruby class (via RBX, similar to JSX) and render other nodes into the output using [Antlers](https://github.com/raindeer-rb/antlers) syntax; `<html><{ ChildNode }></html>`.

## RBX

Use `.rbx` as your file extension and now you can place HTML inside of `render()`:

```ruby
class MyNode < LowNode
  def render
    <p>Hello</p>
  end
end
```

## Antlers

Antlers syntax can be embedded within RBX:
```ruby
class ParentNode < LowNode
  def render
    <html><{ ChildNode }></html>
  end
end

class ChildNode < LowNode
  def render
    <strong>Hello</strong>
  end
end
```

Which outputs:
```HTML
<html><strong>Hello</strong></html>
```

ℹ️ For the full syntax guide see [Antlers](https://github.com/raindeer-rb/antlers).

### Parallelism and Immutability

LowNode converts props to immutable copies, allowing you to run sections of code in parallel:

```ruby
def render
  <{ parallelize: }>
    # For Loop executed at the same time as UserNode.
    <{ for: user in: @users }>
      <{ UserNode user=user }>
    <{ :for }>

    # PostsNode executed at the same time as For Loop.
    <{ PostsNode }>
  <{ :parallelize }>
end
```

## HTML

Use `.rb` as your file extension to render using string interpolation:
```ruby
class MyNode < LowNode
  def initialize
    @greeting = 'Hello'
  end

  def render
    <<~HTML
      <p>#{@greeting}</p>
    HTML
  end
end
```
