# frozen_string_literal: true

require "test_helper"

class Igata
  class CompactNestedClassTest < Minitest::Test
    def test_generate_compact_nested_class
      source = File.read("test/fixtures/formatters/minitest/integration/sources/compact_nested_class.rb")
      expected = File.read("test/fixtures/formatters/minitest/integration/expected/compact_nested_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
