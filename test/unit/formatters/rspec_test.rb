# frozen_string_literal: true

require "test_helper"

class Igata
  module Formatters
    class RSpecFormatterTest < ::Minitest::Test
      def test_generate_simple_class_without_methods # rubocop:disable Metrics/MethodLength
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        method_infos = []

        formatter = RSpec.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "RSpec.describe User do"
        assert_includes result, "require \"spec_helper\""
        refute_includes result, "describe \"#"
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

        formatter = RSpec.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "RSpec.describe User do"
        assert_includes result, "describe \"#initialize\" do"
        assert_includes result, "it \"works correctly\" do"
        assert_includes result, "pending \"Not implemented yet\""
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

        formatter = RSpec.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "describe \"#initialize\" do"
        assert_includes result, "describe \"#adult?\" do"
        assert_includes result, "describe \"#greeting\" do"
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

        formatter = RSpec.new(constant_info, method_infos)
        result = formatter.generate

        assert_includes result, "RSpec.describe User::Profile do"
        assert_includes result, "describe \"#display\" do"
      end

      def test_templates_dir_returns_correct_path
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        formatter = RSpec.new(constant_info, [])

        templates_dir = formatter.send(:templates_dir)

        assert templates_dir.end_with?("lib/igata/formatters/templates/rspec")
        assert File.directory?(templates_dir)
      end

      def test_template_files_exist
        constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        formatter = RSpec.new(constant_info, [])

        class_template = formatter.send(:template_path, "class")
        method_template = formatter.send(:template_path, "method")

        assert File.exist?(class_template), "class.erb template should exist"
        assert File.exist?(method_template), "method.erb template should exist"
      end
    end
  end
end
