# frozen_string_literal: true

require_relative '../lownode'

class UserNode < LowNode
  observe 'users/:id'

  def initialize(event:)
    @user = UserData.find(event[:id])
  end
end
