# frozen_string_literal: true

require "test_helper"

class TestError < Minitest::Test
  # ===== Igata::Error のテスト =====

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

  # ===== Formatters::MethodNotOverriddenError のテスト =====

  def test_method_not_overridden_error_inheritance
    assert Igata::Formatters::MethodNotOverriddenError < Igata::Error
  end

  def test_method_not_overridden_error_raised_in_base_formatter_generate
    formatter = Igata::Formatters::Base.new(nil, [])
    error = assert_raises(Igata::Formatters::MethodNotOverriddenError) do
      formatter.generate
    end
    assert_match(/Igata::Formatters::Base#generate must be implemented/, error.message)
  end

  def test_method_not_overridden_error_can_be_rescued_as_igata_error
    formatter = Igata::Formatters::Base.new(nil, [])
    rescued = false
    begin
      formatter.generate
    rescue Igata::Error
      rescued = true
    end
    assert rescued, "MethodNotOverriddenError should be rescuable as Igata::Error"
  end
end
