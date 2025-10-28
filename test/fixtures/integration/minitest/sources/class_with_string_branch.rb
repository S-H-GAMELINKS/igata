# frozen_string_literal: true

class RoleChecker
  def initialize(role)
    @role = role
  end

  def admin_action
    if @role == "admin"
      "allowed"
    else
      "denied"
    end
  end

  def guest_message
    unless @role == 'guest'
      "Welcome member"
    else
      "Welcome guest"
    end
  end

  def role_name
    case @role
    when "admin"
      "Administrator"
    when "moderator"
      "Moderator"
    else
      "User"
    end
  end
end
