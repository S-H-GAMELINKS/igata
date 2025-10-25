# frozen_string_literal: true

require "test_helper"

class Igata
  class CompactNestedModuleTest < Minitest::Test
    def test_generate_compact_nested_module
      source = File.read("test/fixtures/sources/compact_nested_module.rb")
      expected = File.read("test/fixtures/expected/compact_nested_module_test")

      result = Igata.new(source).generate

      assert_equal expected, result
    end
  end
end
