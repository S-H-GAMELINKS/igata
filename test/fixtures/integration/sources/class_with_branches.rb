# frozen_string_literal: true

class Calculator
  def check(value)
    if value > 0
      "positive"
    else
      "non-positive"
    end
  end

  def validate(user)
    unless user.valid?
      raise "Invalid user"
    end
  end

  def status(code)
    case code
    when 200
      "OK"
    when 404
      "Not Found"
    else
      "Unknown"
    end
  end
end
