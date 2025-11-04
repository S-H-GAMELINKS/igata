# frozen_string_literal: true

require "test_helper"

class Igata
  module Formatters
    # rubocop:disable Metrics/MethodLength
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

      # ===== 追加テスト：初期化とデータ保持 =====

      def test_initialize_stores_constant_info
        constant_info = Igata::Values::ConstantPath.new(
          path: "Admin::User",
          nested: true,
          compact: false
        )
        formatter = Base.new(constant_info, [])

        # インスタンス変数を確認
        assert_equal constant_info, formatter.instance_variable_get(:@constant_info)
      end

      def test_initialize_stores_method_infos
        method_info = Igata::Values::MethodInfo.new(name: "test_method")
        formatter = Base.new(@constant_info, [method_info])

        assert_equal [method_info], formatter.instance_variable_get(:@method_infos)
      end

      def test_initialize_with_multiple_method_infos
        method_infos = [
          Igata::Values::MethodInfo.new(name: "method1"),
          Igata::Values::MethodInfo.new(name: "method2")
        ]
        formatter = Base.new(@constant_info, method_infos)

        assert_equal 2, formatter.instance_variable_get(:@method_infos).size
      end

      # ===== 追加テスト：render_template メソッド =====

      def test_render_template_with_valid_template
        test_formatter = Class.new(Base) do
          private

          def templates_dir
            "test/fixtures/templates"
          end
        end

        # テンポラリファイルを作成
        require "tmpdir"
        Dir.mktmpdir do |dir|
          template_file = File.join(dir, "test_template.erb")
          File.write(template_file, "Hello <%= name %>!")

          formatter = test_formatter.new(@constant_info, [])
          name = "World"

          result = formatter.send(:render_template, template_file, binding)
          assert_equal "Hello World!", result
        end
      end

      def test_render_template_with_trim_mode
        test_formatter = Class.new(Base)

        # テンポラリファイルを作成（trim_modeテスト用）
        require "tmpdir"
        Dir.mktmpdir do |dir|
          template_file = File.join(dir, "trim_test.erb")
          File.write(template_file, "<% if true %>\nLine 1\n<% end %>")

          formatter = test_formatter.new(@constant_info, [])
          result = formatter.send(:render_template, template_file, binding)

          # trim_mode: "<>" により、<% %>の行が削除される
          assert_equal "Line 1\n", result
        end
      end

      def test_render_template_raises_error_for_missing_file
        test_formatter = Class.new(Base)
        formatter = test_formatter.new(@constant_info, [])

        assert_raises(Errno::ENOENT) do
          formatter.send(:render_template, "/nonexistent/template.erb", binding)
        end
      end

      # ===== 追加テスト：template_path メソッド =====

      def test_template_path_with_different_names
        test_formatter = Class.new(Base) do
          private

          def templates_dir
            "/custom/path"
          end
        end

        formatter = test_formatter.new(@constant_info, [])

        assert_equal "/custom/path/main.erb", formatter.send(:template_path, "main")
        assert_equal "/custom/path/helper.erb", formatter.send(:template_path, "helper")
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
