# frozen_string_literal: true

require "test_helper"

class Igata
  class DoubleCompactNestedClassTest < Minitest::Test
    def test_generate_double_compact_nested_class
      source = File.read("test/fixtures/integration/minitest/sources/double_compact_nested_class.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/double_compact_nested_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
