# frozen_string_literal: true

require "test_helper"

class Igata
  class RSpecClassWithStringComparisonTest < Minitest::Test
    def test_generate_class_with_string_comparison_with_rspec_formatter
      source = File.read("test/fixtures/integration/minitest/sources/class_with_string_comparison.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/class_with_string_comparison_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end
  end
end
