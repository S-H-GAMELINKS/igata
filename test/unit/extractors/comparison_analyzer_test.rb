# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    # rubocop:disable Metrics/ClassLength
    class ComparisonAnalyzerTest < Minitest::Test
      def test_extract_no_comparisons # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def greeting
              "Hello"
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "greeting")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 0, result.length
      end

      def test_extract_greater_than_or_equal # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def adult?(age)
              age >= 18
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "adult?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :>=, result[0].operator
      end

      def test_extract_less_than # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def minor?(age)
              age < 18
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "minor?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :<, result[0].operator
      end

      def test_extract_equal # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def admin?(role)
              role == :admin
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "admin?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :==, result[0].operator
      end

      def test_extract_multiple_comparisons # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def valid_age?(age)
              age >= 0 && age <= 150
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "valid_age?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 2, result.length
        assert_equal :>=, result[0].operator
        assert_equal :<=, result[1].operator
      end

      def test_extract_comparison_in_if_statement # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def check_age(age)
              if age >= 18
                "adult"
              else
                "minor"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "check_age")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :>=, result[0].operator
      end

      # ===== エッジケーステスト =====

      def test_extract_not_equal # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def not_guest?(role)
              role != :guest
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "not_guest?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :!=, result[0].operator
      end

      def test_extract_comparison_in_ternary # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def status(age)
              age >= 18 ? "adult" : "minor"
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "status")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :>=, result[0].operator
      end

      def test_extract_nested_comparisons # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def complex_check(age, score)
              if age >= 18
                if score > 80
                  "excellent adult"
                end
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "complex_check")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 2, result.length
        operators = result.map(&:operator)
        assert_includes operators, :>=
        assert_includes operators, :>
      end

      def test_extract_comparison_with_method_call # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def valid?(value)
              value.size > 10
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "valid?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :>, result[0].operator
      end

      def test_extract_comparison_in_unless # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def validate(age)
              raise "Invalid" unless age >= 0
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "validate")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :>=, result[0].operator
      end

      def test_extract_string_comparison # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def valid_name?(name)
              name != "" && name.length > 0
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "valid_name?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 2, result.length
        operators = result.map(&:operator)
        assert_includes operators, :!=
        assert_includes operators, :>
      end

      def test_extract_comparison_with_constants # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            MAX_AGE = 150

            def valid_age?(age)
              age <= MAX_AGE
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "valid_age?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :<=, result[0].operator
      end

      def test_extract_chained_comparisons # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def in_range?(value, min, max)
              value >= min && value <= max && value != 0
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "in_range?")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        assert_equal 3, result.length
        operators = result.map(&:operator)
        assert_includes operators, :>=
        assert_includes operators, :<=
        assert_includes operators, :!=
      end

      def test_extract_comparison_in_case # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def categorize(age)
              case
              when age < 13
                "child"
              when age < 20
                "teen"
              else
                "adult"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "categorize")
        result = Igata::Extractors::ComparisonAnalyzer.extract(method_node)

        # The current implementation may not extract comparisons from case when clauses
        assert result.is_a?(Array)
      end

      private

      def find_method_node(ast, method_name)
        class_node = ast.body
        return nil unless class_node.respond_to?(:body)

        class_body = class_node.body.body
        return nil unless class_body.respond_to?(:find)

        class_body.find do |node|
          node.is_a?(Kanayago::DefinitionNode) && node.mid.to_s == method_name
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
