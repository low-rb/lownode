# frozen_string_literal: true

require_relative '../../lib/lownode'

module Ruby
  # Implements actions as instance methods, and counts how often it's initialized.
  class ActionNode < LowNode
    include Controller

    class << self
      attr_accessor :initialized
    end

    def initialize(event: nil)
      super
      self.class.initialized = (self.class.initialized || 0) + 1
    end

    def receive(event:)
      "received #{event}"
    end

    def get
      'got'
    end

    def post(event:)
      "posted #{event}"
    end

    def put
      Low::Types::Status[204]
    end

    def delete
      Ruby::Node.render
    end

    private

    def patch
      'private actions are not called'
    end
  end

  # Defines a HTTP verb action without "include Controller".
  class PlainNode < LowNode
    def get
      'not a controller'
    end
  end
end

module Ruby
  # Sets cookies and redirects.
  class SessionNode < LowNode
    include Controller

    def post
      set_cookie('session', 'a b', max_age: 3600)
      redirect('/home')
    end

    def get
      set_cookie('theme', 'dark', http_only: false, secure: false, same_site: 'Strict')
      'page'
    end

    def delete
      set_cookie('session', '', max_age: 0)
      Low::Types::Status[204]
    end
  end
end
