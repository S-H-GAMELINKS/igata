# frozen_string_literal: true

require "test_helper"

class Igata
  class TripleNestedClassTest < Minitest::Test
    def test_generate_triple_nested_class
      source = File.read("test/fixtures/formatters/minitest/integration/sources/triple_nested_class.rb")
      expected = File.read("test/fixtures/formatters/minitest/integration/expected/triple_nested_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
