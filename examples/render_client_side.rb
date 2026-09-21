# frozen_string_literal: true

require_relative '../lownode'

class UserNode < LowNode
  observe 'api/v1/users/:id'

  def initialize(event:)
    @user = UserData.find(event[:id])
  end

  def render
    {
      name: @user.name,
      rsvp: @user.rsvp,
      diet: @user.diet
    }
  end
end
