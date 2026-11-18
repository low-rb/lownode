# frozen_string_literal: true

require 'observers'
require 'lowtype'
require 'lowevent'

require_relative 'responses/cookie'
require_relative 'responses/redirect'
require_relative 'templates/renderer'

class LowNode
  extend Observers

  include LowType
  include Low::Events
  include Low::Types
  include Low::Templates::Renderer

  attr_reader :event

  def initialize(event: nil)
    @event = event
  end

  # Headers to send with this node's response when it responds to an event, like the cookies it sets.
  def response_headers
    @response_headers ||= Protocol::HTTP::Headers.new
  end

  # Sets a cookie with this node's response. Expire one with "max_age: 0".
  def set_cookie(name, value, **)
    response_headers.add('set-cookie', Low::Responses::Cookie.new(name:, value:, **).to_s)
  end

  # Return from an action to send the browser to another address: "return redirect('/login')".
  def redirect(location, status: 303)
    Low::Responses::Redirect.new(location:, status:)
  end

  # TODO: Rename "handle" method/action to more specific "route" and maybe split out into module too.
  def handle(event:)
    nil
  end

  class << self
    def handle(event:)
      new(event:).handle(event:)
    end

    def inherited(child)
      child.include LowType
      increase_count
    end

    def count
      @count ||= 0
    end

    def increase_count
      @count = count + 1
    end
  end
end
