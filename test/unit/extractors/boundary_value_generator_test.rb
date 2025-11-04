# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    # rubocop:disable Metrics/ClassLength
    class BoundaryValueGeneratorTest < Minitest::Test
      # Test for >= operator with numeric value
      def test_extract_with_greater_than_or_equal_numeric
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "age", right: "18", context: "age >= 18")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [17, 18, 19], boundary.test_values
        assert_includes boundary.description, "17"
        assert_includes boundary.description, "18"
        assert_includes boundary.description, "19"
      end

      # Test for > operator with numeric value
      def test_extract_with_greater_than_numeric
        comparison = Values::ComparisonInfo.new(operator: :>, left: "value", right: "0", context: "value > 0")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [0, 1], boundary.test_values
      end

      # Test for <= operator with numeric value
      def test_extract_with_less_than_or_equal_numeric
        comparison = Values::ComparisonInfo.new(operator: :<=, left: "count", right: "100", context: "count <= 100")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [99, 100, 101], boundary.test_values
      end

      # Test for < operator with numeric value
      def test_extract_with_less_than_numeric
        comparison = Values::ComparisonInfo.new(operator: :<, left: "age", right: "18", context: "age < 18")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [17, 18], boundary.test_values
      end

      # Test for == operator with numeric value
      def test_extract_with_equal_numeric
        comparison = Values::ComparisonInfo.new(operator: :==, left: "value", right: "42", context: "value == 42")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [41, 42, 43], boundary.test_values
      end

      # Test for != operator with numeric value
      def test_extract_with_not_equal_numeric
        comparison = Values::ComparisonInfo.new(operator: :!=, left: "value", right: "0", context: "value != 0")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [0], boundary.test_values
      end

      # Test with float value
      def test_extract_with_float_value
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "price", right: "18.5", context: "price >= 18.5")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [17.5, 18.5, 19.5], boundary.test_values
      end

      # Test with string literal
      def test_extract_with_string_literal
        comparison = Values::ComparisonInfo.new(operator: :==, left: "name", right: '"Alice"',
                                                context: 'name == "Alice"')
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal %w[Alice different_string], boundary.test_values
      end

      # Test with nil value
      def test_extract_with_nil_value
        comparison = Values::ComparisonInfo.new(operator: :==, left: "user", right: "nil", context: "user == nil")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [nil, "some_value"], boundary.test_values
        assert_includes boundary.description, "nil check"
      end

      # Test with boolean value (true)
      def test_extract_with_true_value
        comparison = Values::ComparisonInfo.new(operator: :==, left: "flag", right: "true", context: "flag == true")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [true, false], boundary.test_values
        assert_includes boundary.description, "boolean check"
      end

      # Test with boolean value (false)
      def test_extract_with_false_value
        comparison = Values::ComparisonInfo.new(operator: :==, left: "flag", right: "false", context: "flag == false")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [true, false], boundary.test_values
      end

      # Test with symbol value
      def test_extract_with_symbol_value
        comparison = Values::ComparisonInfo.new(operator: :==, left: "status", right: ":active",
                                                context: "status == :active")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [":active", ":other_symbol"], boundary.test_values
        assert_includes boundary.description, "symbol check"
      end

      # Test with variable (should return empty - no boundary values)
      def test_extract_with_variable_reference
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "age", right: "MAX_AGE", context: "age >= MAX_AGE")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 0, result.size
      end

      # Test with multiple comparisons
      def test_extract_with_multiple_comparisons
        comparisons = [
          Values::ComparisonInfo.new(operator: :>=, left: "age", right: "18", context: "age >= 18"),
          Values::ComparisonInfo.new(operator: :<, left: "age", right: "65", context: "age < 65")
        ]
        result = BoundaryValueGenerator.extract(comparisons)

        assert_equal 2, result.size
        assert_equal [17, 18, 19], result[0].test_values
        assert_equal [64, 65], result[1].test_values
      end

      # Test with empty comparisons
      def test_extract_with_empty_comparisons
        result = BoundaryValueGenerator.extract([])

        assert_equal 0, result.size
      end

      # ===== エッジケーステスト =====

      # Test with negative number boundary
      def test_extract_with_negative_boundary
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "temp", right: "-10", context: "temp >= -10")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [-11, -10, -9], boundary.test_values
      end

      # Test with zero boundary
      def test_extract_with_zero_boundary
        comparison = Values::ComparisonInfo.new(operator: :>, left: "value", right: "0", context: "value > 0")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [0, 1], boundary.test_values
      end

      # Test with large number
      def test_extract_with_large_number
        comparison = Values::ComparisonInfo.new(operator: :<=, left: "max", right: "9999", context: "max <= 9999")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [9998, 9999, 10_000], boundary.test_values
      end

      # Test with negative float
      def test_extract_with_negative_float
        comparison = Values::ComparisonInfo.new(operator: :<, left: "temp", right: "-5.5",
                                                context: "temp < -5.5")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        assert_equal [-6.5, -5.5], boundary.test_values
      end

      # Test with very small float
      def test_extract_with_small_float
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "ratio", right: "0.1", context: "ratio >= 0.1")
        result = BoundaryValueGenerator.extract([comparison])

        assert_equal 1, result.size
        boundary = result.first
        # Should handle float precision properly
        assert_equal 3, boundary.test_values.size
      end

      # Test with method call on right side
      def test_extract_with_method_call_right_side
        comparison = Values::ComparisonInfo.new(operator: :>, left: "value", right: "array.size",
                                                context: "value > array.size")
        result = BoundaryValueGenerator.extract([comparison])

        # Method calls are not literals, should not generate boundaries
        assert_equal 0, result.size
      end

      # Test with expression on right side
      def test_extract_with_expression_right_side
        comparison = Values::ComparisonInfo.new(operator: :>=, left: "x", right: "y + 10", context: "x >= y + 10")
        result = BoundaryValueGenerator.extract([comparison])

        # Expressions are not literals, should not generate boundaries
        assert_equal 0, result.size
      end

      # Test with constant on right side
      def test_extract_with_constant_right_side
        comparison = Values::ComparisonInfo.new(operator: :<=, left: "age", right: "MAX_AGE", context: "age <= MAX_AGE")
        result = BoundaryValueGenerator.extract([comparison])

        # Constants without numeric value should not generate boundaries
        assert_equal 0, result.size
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
