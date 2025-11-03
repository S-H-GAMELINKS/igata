# frozen_string_literal: true

class Calculator
  def validate_age(age)
    return "未成年" if age < 18
    return "成人" if age >= 18 && age < 65
    return "高齢者" if age >= 65
  end

  def check_range(value)
    return "範囲外" if value < 0 || value > 100
    return "範囲内"
  end

  def check_price(price)
    return "無料" if price == 0
    return "有料"
  end

  def check_name(name)
    return "Alice" if name == "Alice"
    return "その他"
  end

  def check_status(status)
    return "active" if status == :active
    return "inactive"
  end

  def check_flag(enabled)
    return "有効" if enabled == true
    return "無効"
  end

  def check_nil(value)
    return "nil" if value == nil
    return "not nil"
  end

  def simple_method
    puts "Hello"
  end
end
