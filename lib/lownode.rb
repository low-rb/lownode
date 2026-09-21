# frozen_string_literal: true

require 'observers'
require 'lowtype'
require 'lowevent'
require 'lowloop' # TODO: ResponseFactory should be done in LowLoop, which is where the class lives already anyway.

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
