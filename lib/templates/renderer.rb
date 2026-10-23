# frozen_string_literal: true

require_relative 'template'
require 'antlers/keywords'
require 'protocol/http'

module Low
  module Templates
    # Use the Method Factory pattern to ".render -> .new -> #initialize -> #render" a LowNode.
    module Renderer
      # Antlers hook.
      # When render() contains RBX/Antlers then dirload builds a template to render with instead.
      # When lowevent is required then Antlers will send an event keyword argument as well.
      def render_template(parent_binding: nil, slot_node: nil, props: {}, event: nil, **kwargs)
        template = self.class.template

        # NOTE: We currently set local variables on this local binding, not the receiver's binding.
        # TODO: Should we create an "instance_binding" method on LowNode and use that binding instead?
        current_binding = binding

        template.params.each do |param|
          # The event keyword is already a local variable on this binding.
          next if param == :event

          variable = props[param] || kwargs[param] || raise(ArgumentError, "Missing argument: '#{param}'")
          current_binding.local_variable_set(param, variable)
        end

        template.engine.render(ast: template.ast, current_binding:, parent_binding:, slot_node:)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Accepts all arguments but only sends each method the arguments it takes, like initialize(limit:) and render(event:).
        def render(**kwargs)
          # GOAL: Make return value configurable; ResponseEvent, Response, or body.
          body = response_body(**kwargs)

          return if body.nil? || body == ''

          headers = Protocol::HTTP::Headers.new([['content-type', 'text/html']])
          response = Protocol::HTTP::Response.new('HTTP/1.1', response_status(kwargs[:event]), headers, Protocol::HTTP::Body::Buffered.wrap(body.strip))
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # Dirload hook.
        def template
          @template
        end

        # Dirload hook.
        def build_template(template:, params:, engine:, namespace:)
          @template = Template.new(template:, params:, engine:, namespace:)
        end

        private

        # Responses default to 200 but when rendering for a StatusEvent use that event's status code.
        def response_status(event)
          event.is_a?(Low::Events::StatusEvent) ? event.status.status_code : 200
        end

        def response_body(**kwargs)
          node = new(**Antlers::Keywords.accepted(instance_method(:initialize), kwargs))
          return node.render_template(**kwargs) if @template

          node.render(**Antlers::Keywords.accepted(node.method(:render), kwargs))
        end
      end
    end
  end
end
