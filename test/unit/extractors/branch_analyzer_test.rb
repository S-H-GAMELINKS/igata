# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    class BranchAnalyzerTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      def test_extract_no_branches # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def greeting
              "Hello"
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "greeting")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 0, result.length
      end

      def test_extract_single_if_branch # rubocop:disable Metrics/MethodLength
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
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :if, result[0].type
      end

      def test_extract_single_unless_branch # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def check_permission(user)
              unless user.admin?
                raise "Not authorized"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "check_permission")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :unless, result[0].type
      end

      def test_extract_case_branch # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def role_name(role)
              case role
              when :admin
                "Administrator"
              when :user
                "Regular User"
              else
                "Guest"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "role_name")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :case, result[0].type
      end

      def test_extract_multiple_branches # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def complex_check(age, role)
              if age >= 18
                "adult"
              end

              unless role == :guest
                "registered"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "complex_check")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 2, result.length
        assert_equal :if, result[0].type
        assert_equal :unless, result[1].type
      end

      def test_extract_nested_branches # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def nested_check(age, premium)
              if age >= 18
                if premium
                  "premium adult"
                else
                  "regular adult"
                end
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "nested_check")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 2, result.length
        assert_equal :if, result[0].type
        assert_equal :if, result[1].type
      end

      # ===== エッジケーステスト =====

      def test_extract_ternary_operator # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def status(active)
              active ? "active" : "inactive"
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "status")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        # Ternary operator is detected as :if in the current implementation
        assert_equal :if, result[0].type
      end

      def test_extract_elsif_chain # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def grade(score)
              if score >= 90
                "A"
              elsif score >= 80
                "B"
              elsif score >= 70
                "C"
              else
                "F"
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "grade")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        # Each elsif is counted as a separate branch in the current implementation
        assert_equal 3, result.length
        result.each do |branch|
          assert_equal :if, branch.type
        end
      end

      def test_extract_modifier_if # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def process(value)
              return nil if value.nil?
              value
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "process")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :if, result[0].type
      end

      def test_extract_modifier_unless # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def validate(data)
              raise "Invalid" unless data.valid?
              data
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "validate")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :unless, result[0].type
      end

      def test_extract_deeply_nested_branches # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def complex_logic(a, b, c)
              if a > 0
                if b > 0
                  if c > 0
                    "all positive"
                  end
                end
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "complex_logic")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 3, result.length
        result.each do |branch|
          assert_equal :if, branch.type
        end
      end

      def test_extract_case_with_multiple_when # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def permission_level(role)
              case role
              when :admin, :superuser
                3
              when :moderator
                2
              when :user
                1
              else
                0
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "permission_level")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert_equal 1, result.length
        assert_equal :case, result[0].type
      end

      def test_extract_mixed_branch_types # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def process(value, flag)
              return "early" if flag

              result = value > 0 ? "positive" : "negative"

              unless result.nil?
                case result
                when "positive"
                  "good"
                when "negative"
                  "bad"
                end
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        method_node = find_method_node(ast, "process")
        result = Igata::Extractors::BranchAnalyzer.extract(method_node)

        assert result.length >= 3, "Should detect at least 3 branches"
        types = result.map(&:type)
        assert_includes types, :if
        # Ternary is detected as :if in the current implementation
        assert_includes types, :unless
        assert_includes types, :case
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
