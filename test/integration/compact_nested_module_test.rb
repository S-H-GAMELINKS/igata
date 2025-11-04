# frozen_string_literal: true

require "test_helper"

class Igata
  class CompactNestedModuleTest < Minitest::Test
    def test_generate_with_minitest_formatter
      source = File.read("test/fixtures/integration/sources/compact_nested_module.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/compact_nested_module_test")

      result = Igata.new(source, formatter: :minitest).generate

      assert_equal expected, result
    end

    def test_generate_with_rspec_formatter
      source = File.read("test/fixtures/integration/sources/compact_nested_module.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/compact_nested_module_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end
  end
end
