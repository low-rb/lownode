# frozen_string_literal: true

require_relative 'template'
require 'antlers/keywords'
require 'protocol/http'
require 'json'

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
      # Without a body there's no response, so no headers are made for one, like a parent route's side_effect that a
      # node doesn't have.
      def self.define_actions(mod, actions)
        actions.each do |action|
          mod.module_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{action}(**kwargs)
              node, body = action_body(:#{action}, kwargs)
              return if body.nil? || (body.is_a?(String) && body.empty?)

              response_event(body:, event: kwargs[:event], headers: node&.added_headers)
            end
          RUBY
        end
      end

      # Antlers hook.
      # When render() contains RBX/Antlers then dirload builds a template to render with instead.
      # When lowevent is required then Antlers will send an event keyword argument as well.
      # A component rendered inside a template gets the template's render context.
      def render_template(parent_binding: nil, slot_node: nil, props: {}, event: nil, context: {}, **kwargs)
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

        template.engine.render(ast: template.ast, current_binding:, parent_binding:, slot_node:, context:)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      # Each method's keyword names, or :all for one that takes **.
      def self.keyword_names
        @keyword_names ||= {}
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

        # Whether the node does anything for the action, like render with a template, or a side_effect it defines. A
        # router can skip an event no node handles, like a parent route's side_effect.
        def handles?(action)
          (action == :render && !@template.nil?) || method_defined?(action)
        end

        private

        # Only nodes that implement the action are initialized, so a "render" then "get" event initializes a "get" node once.
        # The node, so its response headers can be sent, and what its action returned.
        def action_body(action, kwargs)
          return unless handles?(action)

          template = action == :render && @template

          node = new(**accepted_keywords(instance_method(:initialize), kwargs))
          return [node, node.render_template(**kwargs)] if template

          # The action is public, as method_defined? doesn't include private methods.
          [node, node.__send__(action, **accepted_keywords(instance_method(action), kwargs))]
        end

        # The keywords the method takes, like Antlers::Keywords.accepted, but with its params read once for each method,
        # as reading them makes new objects every time. A method that's defined again, like when a file reloads, is a
        # different method, so its params are read again.
        # When the method takes every keyword given, like a node's initialize(event:), they're passed as they are.
        def accepted_keywords(method, kwargs)
          names = Renderer.keyword_names[method] ||= keyword_names(method.parameters)
          return kwargs if names == :all || kwargs.all? { |key, _| names.include?(key) }

          kwargs.slice(*names)
        end

        def keyword_names(parameters)
          parameters.any? { |type, _| type == :keyrest } ? :all : Antlers::Keywords.declared(parameters).freeze
        end

        # GOAL: Make return value configurable; ResponseEvent, Response, or body.
        def response_event(body:, event:, headers: nil)
          headers ||= Protocol::HTTP::Headers.new
          case body
          when Low::Events::ResponseEvent then body
          when Low::Types::Status::StatusCode then status_response_event(status_code: body.status_code, headers:)
          when Low::Responses::Redirect then redirect_response_event(redirect: body, headers:)
          when Protocol::HTTP::Response then protocol_response_event(response: body, headers:)
          when Hash, Array then json_response_event(data: body, event:, headers:)
          when nil, '' then nil
          else html_response_event(html: body, event:, headers:)
          end
        end

        # What a template or action rendered, as HTML unless the node added its own content type, like text/plain.
        def html_response_event(html:, event:, headers:)
          headers.add('content-type', 'text/html') unless content_type?(headers)
          # A rendered page is a new string, so strip it in place rather than copying it. A frozen string is copied.
          html = html.frozen? ? html.strip : html.tap(&:strip!)
          response = Protocol::HTTP::Response.new('HTTP/1.1', response_status(event), headers, Protocol::HTTP::Body::Buffered.wrap(html))
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # Whether the node set a content type. Its headers are looked through as a list, as include? indexes them all.
        def content_type?(headers)
          headers.fields.any? { |name, _| (name = name.to_s).length == 12 && name.casecmp('content-type') == 0 } # rubocop:disable Style/NumericPredicate
        end

        # A response an action made itself, with the headers the node set, like its cookies, added to its own.
        def protocol_response_event(response:, headers:)
          headers.each { |name, value| response.headers.add(name, value) }
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # A hash or array an action returned, as JSON.
        def json_response_event(data:, event:, headers:)
          headers.add('content-type', 'application/json')
          body = Protocol::HTTP::Body::Buffered.wrap(JSON.generate(data))
          response = Protocol::HTTP::Response.new('HTTP/1.1', response_status(event), headers, body)
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        # Actions like "post" can return "Status[200]" to respond without a body.
        def status_response_event(status_code:, headers:)
          response = Protocol::HTTP::Response.new('HTTP/1.1', status_code, headers, nil)
          Low::Events::ResponseEvent.new(response:).tap(&:branch)
        end

        def redirect_response_event(redirect:, headers:)
          headers.add('location', redirect.location)
          status_response_event(status_code: redirect.status, headers:)
        end

        # Responses default to 200 but when rendering for a StatusEvent use that event's status code.
        def response_status(event)
          event.is_a?(Low::Events::StatusEvent) ? event.status.status_code : 200
        end
      end
    end
  end
end
