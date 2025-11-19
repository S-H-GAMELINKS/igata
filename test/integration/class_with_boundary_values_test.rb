# frozen_string_literal: true

require "test_helper"

class Igata
  # rubocop:disable Metrics/ClassLength
  class ClassWithBoundaryValuesTest < Minitest::Test
    # rubocop:disable Metrics/MethodLength
    def test_generate_class_with_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "class CalculatorTest < Minitest::Test"
      assert_includes output, "def test_validate_age"
      assert_includes output, "def test_check_range"
      assert_includes output, "def test_check_price"
      assert_includes output, "def test_check_name"
      assert_includes output, "def test_check_status"
      assert_includes output, "def test_check_flag"
      assert_includes output, "def test_check_nil"
      assert_includes output, "def test_simple_method"
    end

    def test_generate_class_with_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, "RSpec.describe Calculator"
      assert_includes output, 'describe "#validate_age"'
      assert_includes output, 'describe "#check_range"'
      assert_includes output, 'describe "#check_price"'
      assert_includes output, 'describe "#check_name"'
      assert_includes output, 'describe "#check_status"'
      assert_includes output, 'describe "#check_flag"'
      assert_includes output, 'describe "#check_nil"'
      assert_includes output, 'describe "#simple_method"'
    end

    def test_generate_class_with_boundary_values_with_minitest_spec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest_spec)
      output = igata.generate

      assert_includes output, "describe Calculator do"
      assert_includes output, 'describe "#validate_age"'
      assert_includes output, 'describe "#check_range"'
      assert_includes output, 'describe "#check_price"'
      assert_includes output, 'describe "#check_name"'
      assert_includes output, 'describe "#check_status"'
      assert_includes output, 'describe "#check_flag"'
      assert_includes output, 'describe "#check_nil"'
      assert_includes output, 'describe "#simple_method"'
    end
    # rubocop:enable Metrics/MethodLength

    def test_generate_numeric_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # Test validate_age method with numeric boundaries
      assert_includes output, "# Boundary value suggestions:"
      assert_includes output, "age < 18"
      assert_includes output, "age >= 18"
      assert_includes output, "age < 65"
      assert_includes output, "age >= 65"
    end

    def test_generate_numeric_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # Test validate_age method with numeric boundaries
      assert_includes output, "# Boundary value suggestions:"
      assert_includes output, "age < 18"
      assert_includes output, "age >= 18"
      assert_includes output, "age < 65"
      assert_includes output, "age >= 65"
    end

    def test_generate_string_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # Test check_name method with string literal
      assert_includes output, 'name == "Alice"'
    end

    def test_generate_string_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # Test check_name method with string literal
      assert_includes output, 'name == "Alice"'
    end

    def test_generate_nil_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # Test check_nil method
      assert_includes output, "value == nil"
      assert_includes output, "nil check"
    end

    def test_generate_nil_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # Test check_nil method
      assert_includes output, "value == nil"
      assert_includes output, "nil check"
    end

    def test_generate_boolean_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # Test check_flag method
      assert_includes output, "enabled == true"
      assert_includes output, "boolean check"
    end

    def test_generate_boolean_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # Test check_flag method
      assert_includes output, "enabled == true"
      assert_includes output, "boolean check"
    end

    def test_generate_symbol_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # Test check_status method
      assert_includes output, "status == :active"
      assert_includes output, "symbol check"
    end

    def test_generate_symbol_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # Test check_status method
      assert_includes output, "status == :active"
      assert_includes output, "symbol check"
    end

    def test_method_without_boundary_values_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      # simple_method should not have boundary value suggestions
      lines = output.lines
      simple_method_index = lines.find_index { |l| l.include?("def test_simple_method") }
      refute_nil simple_method_index
      # Check next few lines don't contain boundary value suggestions
      next_lines = lines[simple_method_index..(simple_method_index + 3)].join
      refute_includes next_lines, "# Boundary value suggestions:"
    end

    def test_method_without_boundary_values_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_boundary_values.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      # simple_method should not have boundary value suggestions
      lines = output.lines
      simple_method_index = lines.find_index { |l| l.include?('describe "#simple_method"') }
      refute_nil simple_method_index
      # Check next few lines don't contain boundary value suggestions
      next_lines = lines[simple_method_index..(simple_method_index + 3)].join
      refute_includes next_lines, "# Boundary value suggestions:"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
