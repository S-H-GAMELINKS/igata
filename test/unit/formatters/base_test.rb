# frozen_string_literal: true

require "test_helper"

class Igata
  module Formatters
    class BaseTest < ::Minitest::Test
      def setup
        @constant_info = Igata::Values::ConstantPath.new(
          path: "User",
          nested: false,
          compact: false
        )
        @method_infos = []
        @formatter = Base.new(@constant_info, @method_infos)
      end

      def test_generate_raises_method_not_overridden_error
        error = assert_raises(MethodNotOverriddenError) do
          @formatter.generate
        end

        assert_match(/Base#generate must be implemented/, error.message)
      end

      def test_templates_dir_raises_method_not_overridden_error
        error = assert_raises(MethodNotOverriddenError) do
          @formatter.send(:templates_dir)
        end

        assert_match(/Base#templates_dir must be implemented/, error.message)
      end

      def test_template_path_uses_templates_dir
        # Create a test formatter that implements templates_dir
        test_formatter = Class.new(Base) do
          private

          def templates_dir
            "/test/templates"
          end
        end

        formatter = test_formatter.new(@constant_info, @method_infos)
        path = formatter.send(:template_path, "test")

        assert_equal "/test/templates/test.erb", path
      end
    end
  end
end
