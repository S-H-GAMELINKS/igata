# frozen_string_literal:true

class App::User::Profile
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
