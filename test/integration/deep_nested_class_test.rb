# frozen_string_literal: true

require "test_helper"

class Igata
  class DeepNestedClassTest < Minitest::Test
    def test_generate_deep_nested_class
      source = File.read("test/fixtures/integration/minitest/sources/deep_nested_class.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/deep_nested_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
