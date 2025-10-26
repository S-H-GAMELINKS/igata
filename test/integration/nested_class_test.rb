# frozen_string_literal: true

require "test_helper"

class Igata
  class NestedClassTest < Minitest::Test
    def test_generate_basic_class
      source = File.read("test/fixtures/integration/minitest/sources/nested_class.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/nested_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
