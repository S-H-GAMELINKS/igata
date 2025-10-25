# frozen_string_literal: true

class Igata
  module Values
    ConstantPath = Data.define(
      :path,          # "User::Profile"
      :nested,        # true/false
      :compact        # true/false (compact nested like "class User::Profile")
    )

    MethodInfo = Data.define(
      :name           # "initialize"
    )
  end
end
