require_relative '../lownode'

class UserNode < LowNode
  observe 'users/:id'

  def initialize(event:)
    @user = UserData.find(event[:id])
  end

  def render
    <section id="profile">
      <ul>
        <li>Name: {@user.name}</li>
        <li>RSVP: {@user.rsvp}</li>
        <li>Diet: {@user.diet}</li>
      </ul>
    </section>
  end
end
