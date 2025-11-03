# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    # rubocop:disable Metrics/ClassLength
    class ExceptionAnalyzerTest < Minitest::Test
      def test_extract_no_exceptions # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def greeting
              "Hello"
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "greeting")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        assert_equal 0, result.length
      end

      def test_extract_single_raise_with_class_and_message # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class PaymentProcessor
            def process_payment(amount)
              raise ArgumentError, "Invalid amount" if amount <= 0
              charge_card(amount)
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "process_payment")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :raise, result[0].type
        assert_equal "ArgumentError", result[0].exception_class
        assert_equal "Invalid amount", result[0].message
      end

      def test_extract_raise_with_string_only # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def validate
              raise "Invalid user" unless valid?
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "validate")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :raise, result[0].type
        assert_equal "StandardError", result[0].exception_class
        assert_equal "Invalid user", result[0].message
      end

      def test_extract_rescue_clause # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class PaymentProcessor
            def process
              charge_card
            rescue PaymentError => e
              log_error(e)
              false
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "process")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        rescued = result.select { |e| e.type == :rescue }
        assert_equal 1, rescued.length
        assert_equal "PaymentError", rescued[0].exception_class
      end

      def test_extract_raise_and_rescue # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class PaymentProcessor
            def process_payment(amount)
              raise ArgumentError, "Invalid amount" if amount <= 0
              charge_card(amount)
            rescue PaymentError => e
              log_error(e)
              false
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "process_payment")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        raised = result.select { |e| e.type == :raise }
        rescued = result.select { |e| e.type == :rescue }

        assert_equal 1, raised.length
        assert_equal "ArgumentError", raised[0].exception_class
        assert_equal "Invalid amount", raised[0].message

        assert_equal 1, rescued.length
        assert_equal "PaymentError", rescued[0].exception_class
      end

      def test_extract_multiple_raises # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def validate
              raise "User is nil" unless self
              raise StandardError, "User not found" unless exists?
              true
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "validate")
        result = Igata::Extractors::ExceptionAnalyzer.extract(method_node)

        raised = result.select { |e| e.type == :raise }
        assert_equal 2, raised.length
        assert_equal "StandardError", raised[0].exception_class
        assert_equal "User is nil", raised[0].message
        assert_equal "StandardError", raised[1].exception_class
        assert_equal "User not found", raised[1].message
      end

      private

      def find_method_node(ast, method_name)
        class_node = ast.body
        class_body = class_node.body.body
        class_body.find do |node|
          node.is_a?(Kanayago::DefinitionNode) && node.mid.to_s == method_name
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
