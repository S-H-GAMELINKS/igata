# frozen_string_literal:true

module User::Updator
  def initialize(user)
    @user = user
  end

  def update_name(name)
    @user.name = name
  end

  def update_email(email)
    @user.email = email
  end
end
