class UserActivationJob < Struct.new(:user_id)
  def perform
    #user = User.find(user_id)
    #user.destroy unless user.activated? || user.person.is_template?
  end
end
