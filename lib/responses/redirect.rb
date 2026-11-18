# frozen_string_literal: true

module Low
  module Responses
    # Returned by a node's action to send the browser to another address. 303 makes the browser GET it, as after a form.
    Redirect = Data.define(:location, :status)
  end
end
