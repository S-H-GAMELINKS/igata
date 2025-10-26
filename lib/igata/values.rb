# frozen_string_literal: true

class Igata
  module Values
    ConstantPath = Data.define(
      :path,          # "User::Profile"
      :nested,        # true/false
      :compact        # true/false (compact nested like "class User::Profile")
    )

    MethodInfo = Data.define(
      :name,          # "initialize"
      :branches       # Array of BranchInfo (default: [])
    ) do
      def initialize(name:, branches: [])
        super(name: name, branches: branches)
      end
    end

    BranchInfo = Data.define(
      :type,          # :if, :unless, :case, :ternary
      :condition      # condition expression as string
    )
  end
end
