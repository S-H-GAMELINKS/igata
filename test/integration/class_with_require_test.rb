# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithRequireTest < Minitest::Test
    def test_generate_class_with_require
      source = File.read("test/fixtures/integration/minitest/sources/class_with_require.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/class_with_require_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
