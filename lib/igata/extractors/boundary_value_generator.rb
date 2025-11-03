# frozen_string_literal: true

class Igata
  module Extractors
    # rubocop:disable Metrics/ClassLength, Lint/DuplicateBranch, Naming/PredicateMethod
    class BoundaryValueGenerator
      def self.extract(comparisons)
        new(comparisons).extract
      end

      def initialize(comparisons)
        @comparisons = comparisons
      end

      def extract
        @comparisons.map do |comparison|
          generate_boundary_values(comparison)
        end.compact
      end

      private

      def generate_boundary_values(comparison) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        right_value = comparison.right

        # Determine value type and generate appropriate boundary values
        test_values, description = if numeric?(right_value)
                                     generate_numeric_boundaries(comparison)
                                   elsif string_literal?(right_value)
                                     generate_string_boundaries(comparison)
                                   elsif nil_value?(right_value)
                                     generate_nil_boundaries(comparison)
                                   elsif boolean_value?(right_value)
                                     generate_boolean_boundaries(comparison)
                                   elsif symbol_value?(right_value)
                                     generate_symbol_boundaries(comparison)
                                   else
                                     # Variable or method call - skip boundary value generation
                                     return nil
                                   end

        return nil if test_values.nil? || test_values.empty?

        Values::BoundaryValueInfo.new(
          comparison: comparison,
          test_values: test_values,
          description: description
        )
      end

      # Numeric boundary values
      # rubocop:disable Metrics/MethodLength
      def generate_numeric_boundaries(comparison)
        value = parse_numeric(comparison.right)
        operator = comparison.operator

        test_values = case operator
                      when :>=
                        [value - 1, value, value + 1]
                      when :>
                        [value, value + 1]
                      when :<=
                        [value - 1, value, value + 1]
                      when :<
                        [value - 1, value]
                      when :==
                        [value - 1, value, value + 1]
                      when :!=
                        [value]
                      else
                        []
                      end

        description = build_numeric_description(operator, value, test_values)
        [test_values, description]
      end
      # rubocop:enable Metrics/MethodLength

      # String literal boundary values
      # rubocop:disable Metrics/MethodLength
      def generate_string_boundaries(comparison)
        str_value = parse_string(comparison.right)
        operator = comparison.operator

        test_values = case operator
                      when :>=, :>
                        # For string comparison: previous, same, next
                        [decrement_string(str_value), str_value, increment_string(str_value)]
                      when :<=, :<
                        [decrement_string(str_value), str_value, increment_string(str_value)]
                      when :==
                        [str_value, "different_string"]
                      when :!=
                        [str_value, "different_string"]
                      else
                        []
                      end

        description = build_string_description(operator, str_value, test_values)
        [test_values, description]
      end
      # rubocop:enable Metrics/MethodLength

      # Nil boundary values
      # rubocop:disable Metrics/MethodLength
      def generate_nil_boundaries(comparison)
        operator = comparison.operator

        test_values = case operator
                      when :==
                        [nil, "some_value"]
                      when :!=
                        [nil, "some_value"]
                      else
                        []
                      end

        description = "nil check: test with #{test_values.inspect}"
        [test_values, description]
      end
      # rubocop:enable Metrics/MethodLength

      # Boolean boundary values
      def generate_boolean_boundaries(comparison)
        operator = comparison.operator

        test_values = case operator
                      when :==, :!=
                        [true, false]
                      else
                        []
                      end

        description = "boolean check: test with #{test_values.inspect}"
        [test_values, description]
      end

      # Symbol boundary values
      # rubocop:disable Metrics/MethodLength
      def generate_symbol_boundaries(comparison)
        sym_value = parse_symbol(comparison.right)
        operator = comparison.operator

        test_values = case operator
                      when :==
                        [sym_value, ":other_symbol"]
                      when :!=
                        [sym_value, ":other_symbol"]
                      else
                        []
                      end

        description = "symbol check: test with #{test_values.inspect}"
        [test_values, description]
      end
      # rubocop:enable Metrics/MethodLength

      # Type detection methods
      def numeric?(str)
        # Check if string is a numeric literal (integer or float)
        return false if str.nil? || str.empty?

        # Remove quotes if present (shouldn't be for numbers but just in case)
        clean_str = str.gsub(/["']/, "")
        # Match integer or float
        clean_str.match?(/\A-?\d+(\.\d+)?\z/)
      end

      def string_literal?(str)
        # Check if string is a string literal (starts and ends with quotes)
        return false if str.nil? || str.empty?

        str.match?(/\A["'].*["']\z/)
      end

      def nil_value?(str)
        str == "nil"
      end

      def boolean_value?(str)
        %w[true false].include?(str)
      end

      def symbol_value?(str)
        return false if str.nil? || str.empty?

        str.start_with?(":")
      end

      # Parsing methods
      def parse_numeric(str)
        clean_str = str.gsub(/["']/, "")
        clean_str.include?(".") ? clean_str.to_f : clean_str.to_i
      end

      def parse_string(str)
        # Remove surrounding quotes
        str.gsub(/\A["']|["']\z/, "")
      end

      def parse_boolean(str)
        str == "true"
      end

      def parse_symbol(str)
        str # Keep as is with colon
      end

      # String manipulation for boundary values
      # rubocop:disable Metrics/MethodLength
      def increment_string(str)
        # Simple increment: "A" -> "B", "Z" -> "AA"
        if str.empty?
          "A"
        elsif str == "Z"
          "AA"
        else
          last_char = str[-1]
          if last_char == "z"
            "#{str[0..-2]}aa"
          else
            str[0..-2] + last_char.next
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def decrement_string(str)
        # Simple decrement: "B" -> "A", "A" -> ""
        return "" if str.empty?
        return "" if str == "A"

        last_char = str[-1]
        if last_char == "a"
          str[0..-2]
        else
          str[0..-2] + (last_char.ord - 1).chr
        end
      end

      # Description builders
      def build_numeric_description(operator, value, test_values) # rubocop:disable Metrics/MethodLength
        case operator
        when :>=
          "#{value - 1} (below), #{value} (boundary), #{value + 1} (above)"
        when :>
          "#{value} (boundary), #{value + 1} (above)"
        when :<=
          "#{value - 1} (below), #{value} (boundary), #{value + 1} (above)"
        when :<
          "#{value - 1} (below), #{value} (boundary)"
        when :==
          "#{value - 1} (not equal), #{value} (equal), #{value + 1} (not equal)"
        when :!=
          "#{value} (equal)"
        else
          test_values.inspect
        end
      end

      def build_string_description(operator, str_value, test_values)
        case operator
        when :>=, :>, :<=, :<
          "string comparison: #{test_values.inspect}"
        when :==
          "equal: #{str_value.inspect}, not equal: different string"
        when :!=
          "equal: #{str_value.inspect}, not equal: different string"
        else
          test_values.inspect
        end
      end
    end
    # rubocop:enable Metrics/ClassLength, Lint/DuplicateBranch, Naming/PredicateMethod
  end
end
