# frozen_string_literal: true

class Validator
  def adult?(age)
    age >= 18
  end

  def minor?(age)
    age < 18
  end

  def equal_check(value)
    value == 100
  end

  def valid_range?(value)
    value >= 0 && value <= 150
  end

  def check_status(score)
    if score > 80
      "excellent"
    else
      "normal"
    end
  end
end
