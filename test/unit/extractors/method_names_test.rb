# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    class MethodNamesTest < Minitest::Test
      def test_extract_single_method # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def initialize
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        class_node = ast.body
        result = Igata::Extractors::MethodNames.extract(class_node)

        assert_equal 1, result.length
        assert_equal "initialize", result[0].name
      end

      def test_extract_multiple_methods # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def initialize
            end

            def adult?
            end

            def greeting
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        class_node = ast.body
        result = Igata::Extractors::MethodNames.extract(class_node)

        assert_equal 3, result.length
        assert_equal "initialize", result[0].name
        assert_equal "adult?", result[1].name
        assert_equal "greeting", result[2].name
      end

      def test_extract_no_methods
        code = <<~RUBY
          class User
          end
        RUBY

        ast = Kanayago.parse(code)
        class_node = ast.body
        result = Igata::Extractors::MethodNames.extract(class_node)

        assert_equal 0, result.length
      end

      def test_extract_methods_with_parameters # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def initialize(name, age)
            end

            def update(name)
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        class_node = ast.body
        result = Igata::Extractors::MethodNames.extract(class_node)

        assert_equal 2, result.length
        assert_equal "initialize", result[0].name
        assert_equal "update", result[1].name
      end

      def test_extract_methods_from_nested_class # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            class Profile
              def initialize
              end

              def display
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        # Find the inner Profile class
        inner_class = ast.body.body.body.find { |node| node.is_a?(Kanayago::ClassNode) }
        result = Igata::Extractors::MethodNames.extract(inner_class)

        assert_equal 2, result.length
        assert_equal "initialize", result[0].name
        assert_equal "display", result[1].name
      end

      def test_method_info_structure # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def greeting
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        class_node = ast.body
        result = Igata::Extractors::MethodNames.extract(class_node)

        method_info = result[0]
        assert_instance_of Igata::Values::MethodInfo, method_info
        assert_respond_to method_info, :name
      end
    end
  end
end
