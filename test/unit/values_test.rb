# frozen_string_literal: true

require "test_helper"

class Igata
  module Values
    # rubocop:disable Metrics/ClassLength, Metrics/MethodLength
    class ValuesTest < Minitest::Test
      # ===== ConstantPath のテスト =====

      def test_constant_path_creation
        info = ConstantPath.new(path: "User", nested: false, compact: false)
        assert_equal "User", info.path
        assert_equal false, info.nested
        assert_equal false, info.compact
      end

      def test_constant_path_with_nested
        info = ConstantPath.new(path: "App::User", nested: true, compact: false)
        assert_equal "App::User", info.path
        assert info.nested
        refute info.compact
      end

      def test_constant_path_immutability
        info = ConstantPath.new(path: "User", nested: false, compact: false)
        # Data.define creates immutable objects without setter methods
        assert_raises(NoMethodError) { info.path = "Admin" }
      end

      # ===== MethodInfo のテスト =====

      def test_method_info_creation_with_defaults
        info = MethodInfo.new(name: "test_method")
        assert_equal "test_method", info.name
        assert_equal [], info.branches
        assert_equal [], info.comparisons
        assert_equal [], info.exceptions
        assert_equal [], info.boundary_values
      end

      def test_method_info_creation_with_all_fields
        branch = BranchInfo.new(type: :if, condition: "x > 0")
        comparison = ComparisonInfo.new(operator: :>, left: "x", right: "0", context: "x > 0")

        info = MethodInfo.new(
          name: "validate",
          branches: [branch],
          comparisons: [comparison],
          exceptions: [],
          boundary_values: []
        )

        assert_equal "validate", info.name
        assert_equal 1, info.branches.size
        assert_equal 1, info.comparisons.size
      end

      def test_method_info_immutability
        info = MethodInfo.new(name: "test")
        # Data.define creates immutable objects without setter methods
        assert_raises(NoMethodError) { info.name = "changed" }
      end

      # ===== BranchInfo のテスト =====

      def test_branch_info_creation
        info = BranchInfo.new(type: :if, condition: "user.active?")
        assert_equal :if, info.type
        assert_equal "user.active?", info.condition
      end

      def test_branch_info_with_different_types
        %i[if unless case ternary].each do |branch_type|
          info = BranchInfo.new(type: branch_type, condition: "test")
          assert_equal branch_type, info.type
        end
      end

      # ===== ComparisonInfo のテスト =====

      def test_comparison_info_creation
        info = ComparisonInfo.new(
          operator: :>=,
          left: "age",
          right: "18",
          context: "age >= 18"
        )
        assert_equal :>=, info.operator
        assert_equal "age", info.left
        assert_equal "18", info.right
        assert_equal "age >= 18", info.context
      end

      # ===== ExceptionInfo のテスト =====

      def test_exception_info_for_raise
        info = ExceptionInfo.new(
          type: :raise,
          exception_class: "ArgumentError",
          message: "Invalid input",
          context: "raise ArgumentError, 'Invalid input'"
        )
        assert_equal :raise, info.type
        assert_equal "ArgumentError", info.exception_class
        assert_equal "Invalid input", info.message
      end

      def test_exception_info_for_rescue
        info = ExceptionInfo.new(
          type: :rescue,
          exception_class: "StandardError",
          message: nil,
          context: "rescue StandardError"
        )
        assert_equal :rescue, info.type
        assert_equal "StandardError", info.exception_class
        assert_nil info.message
      end

      # ===== BoundaryValueInfo のテスト =====

      def test_boundary_value_info_creation
        comparison = ComparisonInfo.new(
          operator: :>=,
          left: "age",
          right: "18",
          context: "age >= 18"
        )

        info = BoundaryValueInfo.new(
          comparison: comparison,
          test_values: [17, 18, 19],
          description: "Boundary: 17 (below), 18 (boundary), 19 (above)"
        )

        assert_equal comparison, info.comparison
        assert_equal [17, 18, 19], info.test_values
        assert_match(/Boundary/, info.description)
      end
    end
    # rubocop:enable Metrics/ClassLength, Metrics/MethodLength
  end
end
