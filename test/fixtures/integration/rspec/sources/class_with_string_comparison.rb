# frozen_string_literal: true

class StatusChecker
  def initialize(status)
    @status = status
  end

  def active?
    @status == "active"
  end

  def pending?
    @status == 'pending'
  end

  def check_type(type)
    type != "invalid"
  end
end
