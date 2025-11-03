# frozen_string_literal: true

class PaymentProcessor
  def process_payment(amount)
    raise ArgumentError, "Invalid amount" if amount <= 0

    result = charge_card(amount)
    result
  rescue PaymentError => e
    log_error(e)
    false
  end

  def validate_user(user)
    raise "User is nil" unless user
    raise StandardError, "User not found" unless user.exists?

    true
  end

  def simple_method
    "no exceptions here"
  end
end
