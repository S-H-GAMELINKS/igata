# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithStringComparisonTest < Minitest::Test
    def test_generate_with_minitest_formatter
      source = File.read("test/fixtures/integration/sources/class_with_string_comparison.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/class_with_string_comparison_test")

      result = Igata.new(source, formatter: :minitest).generate

      assert_equal expected, result
    end

    def test_generate_with_rspec_formatter
      source = File.read("test/fixtures/integration/sources/class_with_string_comparison.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/class_with_string_comparison_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end
  end
end
