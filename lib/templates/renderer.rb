# frozen_string_literal: true

require_relative 'template'

module Low
  module Templates
    # Use the Method Factory pattern to ".render -> .new -> #initialize -> #render" a LowNode.
    module Renderer
      # When render() contains RBX/Antlers then Dirload builds a template to render with instead.
      def render_template(parent_binding: nil, slot_node: nil, props: {}, **kwargs)
        template = self.class.template

        # NOTE: We currently set local variables on this local binding, not the receiver's binding.
        # TODO: Should we create an "instance_binding" method on LowNode and use that binding instead?
        current_binding = binding

        template.params.each do |param|
          variable = props[param] || kwargs[param] || raise(ArgumentError, "Missing argument: '#{param}'")
          current_binding.local_variable_set(param, variable)
        end

        template.engine.render(ast: template.ast, current_binding:, parent_binding:, slot_node:)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Accepts all arguments but only sends arguments required by the sub class.
        def render(**)
          # GOAL: Make return value configurable; ResponseEvent, Response, or body.
          body = response_body(**)

          return if body.nil? || body == ''

          # TODO: ResponseFactory should be done in LowLoop, which is where the class lives already anyway.
          response = Low::ResponseFactory.html(body:)
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

        def response_body(**kwargs)
          node = new(**kwargs)

          return node.render_template(**kwargs) if @template
          return node.render(**kwargs) if node.method(:render).arity > 0

          node.render
        end
      end
    end
  end
end
