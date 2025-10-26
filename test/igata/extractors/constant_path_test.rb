# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    class ConstantPathTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      def test_simple_class
        code = <<~RUBY
          class User
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User", result.path
        assert_equal false, result.nested
        assert_equal false, result.compact
      end

      def test_compact_nested_class
        code = <<~RUBY
          class User::Profile
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User::Profile", result.path
        assert_equal false, result.nested
        assert_equal true, result.compact
      end

      def test_double_compact_nested_class
        code = <<~RUBY
          class App::Model::User
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "App::Model::User", result.path
        assert_equal false, result.nested
        assert_equal true, result.compact
      end

      def test_regular_nested_class # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            class Profile
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User::Profile", result.path
        assert_equal true, result.nested
        assert_equal false, result.compact
      end

      def test_deep_nested_class # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class App
            class User
              class Profile
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "App::User::Profile", result.path
        assert_equal true, result.nested
        assert_equal false, result.compact
      end

      def test_mixed_nested_class_compact_outer # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class App::User
            class Profile
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "App::User::Profile", result.path
        assert_equal true, result.nested
        assert_equal true, result.compact
      end

      def test_mixed_nested_class_compact_inner # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            class App::Profile
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User::App::Profile", result.path
        assert_equal true, result.nested
        assert_equal false, result.compact
      end

      def test_triple_nested_mixed # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class App::Model
            class Admin::User
              class Profile
              end
            end
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "App::Model::Admin::User::Profile", result.path
        assert_equal true, result.nested
        assert_equal true, result.compact
      end

      def test_module
        code = <<~RUBY
          module User
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User", result.path
        assert_equal false, result.nested
        assert_equal false, result.compact
      end

      def test_compact_nested_module
        code = <<~RUBY
          module User::Updator
          end
        RUBY

        ast = Kanayago.parse(code)
        result = Igata::Extractors::ConstantPath.extract(ast)

        assert_equal "User::Updator", result.path
        assert_equal false, result.nested
        assert_equal true, result.compact
      end
    end
  end
end
