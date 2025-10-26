# frozen_string_literal: true

require "test_helper"

class Igata
  class RSpecBasicClassTest < Minitest::Test
    def test_generate_basic_class_with_rspec_formatter
      source = File.read("test/fixtures/integration/minitest/sources/basic_class.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/basic_class_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end
  end
end
