# frozen_string_literal: true

require "test_helper"

class Igata
  class RSpecClassWithExceptionsTest < Minitest::Test
    def test_generate_rspec_class_with_exceptions
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, "RSpec.describe PaymentProcessor do"
      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, 'describe "#validate_user" do'
      assert_includes output, 'describe "#simple_method" do'
    end

    def test_generate_rspec_method_with_raise
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, '# Exceptions raised: ArgumentError ("Invalid amount")'
    end

    def test_generate_rspec_method_with_rescue
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, "# Exceptions rescued: PaymentError"
    end

    def test_generate_rspec_method_with_multiple_raises
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#validate_user" do'
      assert_includes output, '# Exceptions raised: StandardError ("User is nil"), StandardError ("User not found")'
    end
  end
end
