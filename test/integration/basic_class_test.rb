# frozen_string_literal: true

require "test_helper"

class Igata
  class BasicClassTest < Minitest::Test
    def test_generate_basic_class
      source = File.read("test/fixtures/integration/minitest/sources/basic_class.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/basic_class_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
