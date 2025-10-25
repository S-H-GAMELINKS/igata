# frozen_string_literal:true

class App::Model
  class Admin::User
    class Profile
      def initialize(name, age)
        @name = name
        @age = age
      end

      def adult?
        @age >= 18
      end

      def greeting
        "Hi, #{@name}"
      end
    end
  end
end
