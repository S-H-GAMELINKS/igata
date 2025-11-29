# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithArgumentsTest < Minitest::Test
    def test_generate_with_minitest_formatter
      source = File.read("test/fixtures/integration/sources/class_with_arguments.rb")
      expected = File.read("test/fixtures/integration/minitest/expected/class_with_arguments_test")

      result = Igata.new(source, formatter: :minitest).generate

      assert_equal expected, result
    end

    def test_generate_with_rspec_formatter
      source = File.read("test/fixtures/integration/sources/class_with_arguments.rb")
      expected = File.read("test/fixtures/integration/rspec/expected/class_with_arguments_spec")

      result = Igata.new(source, formatter: :rspec).generate

      assert_equal expected, result
    end

    def test_generate_with_minitest_spec_formatter
      source = File.read("test/fixtures/integration/sources/class_with_arguments.rb")
      expected = File.read("test/fixtures/integration/minitest_spec/expected/class_with_arguments_spec")

      result = Igata.new(source, formatter: :minitest_spec).generate

      assert_equal expected, result
    end
  end
end
