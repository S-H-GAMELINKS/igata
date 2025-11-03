# frozen_string_literal: true

class Igata
  module Values
    ConstantPath = Data.define(
      :path,          # "User::Profile"
      :nested,        # true/false
      :compact        # true/false (compact nested like "class User::Profile")
    )

    MethodInfo = Data.define(
      :name,            # "initialize"
      :branches,        # Array of BranchInfo (default: [])
      :comparisons,     # Array of ComparisonInfo (default: [])
      :exceptions,      # Array of ExceptionInfo (default: [])
      :boundary_values  # Array of BoundaryValueInfo (default: [])
    ) do
      def initialize(name:, branches: [], comparisons: [], exceptions: [], boundary_values: [])
        super(name: name, branches: branches, comparisons: comparisons, exceptions: exceptions,
              boundary_values: boundary_values)
      end
    end

    BranchInfo = Data.define(
      :type,          # :if, :unless, :case, :ternary
      :condition      # condition expression as string
    )

    ComparisonInfo = Data.define(
      :operator,      # :>=, :<=, :>, :<, :==, :!=
      :left,          # left side expression
      :right,         # right side expression
      :context        # full expression as string (e.g., "age >= 18")
    )

    ExceptionInfo = Data.define(
      :type,            # :raise or :rescue
      :exception_class, # exception class name (e.g., "ArgumentError", "StandardError")
      :message,         # message for raise (e.g., "Invalid amount")
      :context          # full expression as string
    )

    BoundaryValueInfo = Data.define(
      :comparison,      # ComparisonInfo object
      :test_values,     # Array of test values (e.g., [17, 18, 19])
      :description      # description string (e.g., "Boundary: 17 (below), 18 (boundary), 19 (above)")
    )
  end
end
