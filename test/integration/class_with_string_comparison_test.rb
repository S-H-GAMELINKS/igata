# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithStringComparisonTest < Minitest::Test
    def test_generate_class_with_string_comparison
      source = File.read("test/fixtures/integration/minitest/sources/class_with_string_comparison.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/class_with_string_comparison_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
