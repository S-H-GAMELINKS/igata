# frozen_string_literal: true

require "test_helper"

class TestError < Minitest::Test
  def test_error_is_standard_error
    assert Igata::Error < StandardError
  end

  def test_error_can_be_raised_with_message
    error = assert_raises(Igata::Error) do
      raise Igata::Error, "test error message"
    end
    assert_equal "test error message", error.message
  end

  def test_error_can_be_rescued_as_standard_error
    rescued = false
    begin
      raise Igata::Error, "test"
    rescue StandardError
      rescued = true
    end
    assert rescued, "Igata::Error should be rescuable as StandardError"
  end

  def test_method_not_overridden_error_inheritance
    assert Igata::Formatters::MethodNotOverriddenError < Igata::Error
  end

  def test_constant_info_is_nil_raised_in_base_formatter_generate
    formatter = Igata::Formatters::Base.new(nil, [])

    error = assert_raises(NoMethodError) do
      formatter.generate
    end

    assert_match "undefined method 'path' for nil", error.message
  end
end
