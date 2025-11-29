# frozen_string_literal: true

class User
  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet(message = "Hello")
    puts message
  end

  def create(verified: false)
    # creation logic
  end

  def process(*args, **kwargs, &block)
    # complex processing
  end

  def simple
    # no arguments
  end
end
