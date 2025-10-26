# frozen_string_literal: true

require "test_helper"

class Igata
  module Formatters
    class MinitestFormatterTest < ::Minitest::Test
      def test_generate_simple_class_without_methods # rubocop:disable Metrics/MethodLength
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        method_infos = []

        formatter = Minitest.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "class UserTest < Minitest::Test"
        assert_includes result, "require \"test_helper\""
        refute_includes result, "def test_"
      end

      def test_generate_class_with_single_method # rubocop:disable Metrics/MethodLength
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        method_infos = [
          Igata::Values::MethodInfo.new(name: "initialize")
        ]

        formatter = Minitest.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "class UserTest < Minitest::Test"
        assert_includes result, "def test_initialize"
        assert_includes result, "skip \"Not implemented yet\""
      end

      def test_generate_class_with_multiple_methods # rubocop:disable Metrics/MethodLength
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        method_infos = [
          Igata::Values::MethodInfo.new(name: "initialize"),
          Igata::Values::MethodInfo.new(name: "adult?"),
          Igata::Values::MethodInfo.new(name: "greeting")
        ]

        formatter = Minitest.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "def test_initialize"
        assert_includes result, "def test_adult?"
        assert_includes result, "def test_greeting"
      end

      def test_generate_nested_class # rubocop:disable Metrics/MethodLength
        constant_info = Igata::Values::ConstantPath.new(
          path: "User::Profile",
          nested: true,
          compact: false
        )
        method_infos = [
          Igata::Values::MethodInfo.new(name: "display")
        ]

        formatter = Minitest.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "class User::ProfileTest < Minitest::Test"
        assert_includes result, "def test_display"
      end

      def test_templates_dir_returns_correct_path
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        formatter = Minitest.new(constant_info, [])

        templates_dir = formatter.send(:templates_dir)

        assert templates_dir.end_with?("lib/igata/formatters/templates/minitest")
        assert File.directory?(templates_dir)
      end

      def test_template_files_exist
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        formatter = Minitest.new(constant_info, [])

        class_template = formatter.send(:template_path, "class")
        method_template = formatter.send(:template_path, "method")

        assert File.exist?(class_template), "class.erb template should exist"
        assert File.exist?(method_template), "method.erb template should exist"
      end
    end
  end
end
