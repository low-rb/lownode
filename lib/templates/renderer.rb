# frozen_string_literal: true

require_relative 'template'
require 'antlers/keywords'
require 'protocol/http'

module Low
  module Templates
    # Use the Method Factory pattern to ".render -> .new -> #initialize -> #render" a LowNode, and the same for its other actions.
    module Renderer
      # Observers call actions on the node class, which the Method Factory pattern turns into the node's instance methods:
      # ".receive -> .new -> #initialize -> #receive". Defining them up front avoids a method_missing lookup on every event.
      ACTIONS = %i[render receive side_effect].freeze

      # The HTTP verb actions, which a node has when it does "include Controller".
      CONTROLLER_ACTIONS = %i[get query post put patch delete].freeze

      # Accepts all arguments but only sends each method the arguments it takes, like initialize(limit:) and render(event:).
      # Defined with "def" rather than "define_method" because a block with keyword arguments is slower to call.
      def self.define_actions(mod, actions)
        actions.each do |action|
          mod.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{action}(**kwargs)
              response_event(body: action_body(:#{action}, kwargs), event: kwargs[:event])
            end
          RUBY
        end
      end

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

      # Adds the HTTP verb actions to a node with "include Controller", so it can respond with "def get" and "def post".
      module Controller
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          Renderer.define_actions(self, CONTROLLER_ACTIONS)
        end
      end

      module ClassMethods
        Renderer.define_actions(self, ACTIONS)

        # Dirload hook.
        def template
          @template
        end

        # Dirload hook.
        def build_template(template:, params:, engine:, namespace:)
          @template = Template.new(template:, params:, engine:, namespace:)
        end

        private

        # Only nodes that implement the action are initialized, so a "render" then "get" event initializes a "get" node once.
        def action_body(action, kwargs)
          template = action == :render && @template
          return unless template || method_defined?(action)

          node = new(**Antlers::Keywords.accepted(instance_method(:initialize), kwargs))
          return node.render_template(**kwargs) if template

          # The action is public, as method_defined? doesn't include private methods.
          node.__send__(action, **Antlers::Keywords.accepted(node.method(action), kwargs))
        end

        # GOAL: Make return value configurable; ResponseEvent, Response, or body.
        def response_event(body:, event:)
          unless body.is_a?(String)
            return body if body.is_a?(Low::Events::ResponseEvent)
            return status_response_event(status_code: body.status_code) if body.is_a?(Low::Types::Status::StatusCode)
          end
          return if body.nil? || body == ''

          headers = Protocol::HTTP::Headers.new([['content-type', 'text/html']])
          response = Protocol::HTTP::Response.new('HTTP/1.1', response_status(event), headers, Protocol::HTTP::Body::Buffered.wrap(body.strip))
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # Actions like "post" can return "Status[200]" to respond without a body.
        def status_response_event(status_code:)
          response = Protocol::HTTP::Response.new('HTTP/1.1', status_code, Protocol::HTTP::Headers.new, nil)
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # Responses default to 200 but when rendering for a StatusEvent use that event's status code.
        def response_status(event)
          event.is_a?(Low::Events::StatusEvent) ? event.status.status_code : 200
        end
      end
    end
  end
end
