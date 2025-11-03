# frozen_string_literal: true

require "test_helper"

class Igata
  class DeepNestedClassTest < Minitest::Test
    def test_generate_with_minitest_formatter
      source = File.read("test/fixtures/integration/sources/deep_nested_class.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/deep_nested_class_test")

      result = Igata.new(source, formatter: :minitest).generate

      assert_equal expected, result
    end

    def test_generate_with_rspec_formatter
      source = File.read("test/fixtures/integration/sources/deep_nested_class.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/deep_nested_class_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end
  end
end
