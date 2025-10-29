# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithNoMethodsTest < Minitest::Test
    def test_generate_class_with_no_methods
      source = File.read("test/fixtures/integration/minitest/sources/class_with_no_methods.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/class_with_no_methods_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
