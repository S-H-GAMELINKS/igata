# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
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
  end
end
