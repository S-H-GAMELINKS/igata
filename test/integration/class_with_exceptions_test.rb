# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithExceptionsTest < Minitest::Test
    def test_generate_class_with_exceptions_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "class PaymentProcessorTest < Minitest::Test"
      assert_includes output, "def test_process_payment"
      assert_includes output, "def test_validate_user"
      assert_includes output, "def test_simple_method"
    end

    def test_generate_class_with_exceptions_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, "RSpec.describe PaymentProcessor do"
      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, 'describe "#validate_user" do'
      assert_includes output, 'describe "#simple_method" do'
    end

    def test_generate_method_with_raise_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_process_payment"
      assert_includes output, '# Exceptions raised: ArgumentError ("Invalid amount")'
    end

    def test_generate_method_with_raise_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, '# Exceptions raised: ArgumentError ("Invalid amount")'
    end

    def test_generate_method_with_rescue_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_process_payment"
      assert_includes output, "# Exceptions rescued: PaymentError"
    end

    def test_generate_method_with_rescue_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#process_payment" do'
      assert_includes output, "# Exceptions rescued: PaymentError"
    end

    def test_generate_method_with_multiple_raises_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_validate_user"
      assert_includes output, '# Exceptions raised: StandardError ("User is nil"), StandardError ("User not found")'
    end

    def test_generate_method_with_multiple_raises_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#validate_user" do'
      assert_includes output, '# Exceptions raised: StandardError ("User is nil"), StandardError ("User not found")'
    end

    # rubocop:disable Metrics/AbcSize, Layout/LineLength
    def test_generate_method_without_exceptions_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_simple_method"
      # Should not include exception comments
      refute_match(/# Exceptions/, output.lines.grep(/def test_simple_method/).join("\n") + output.lines[output.lines.find_index { |l|
        l.include?("def test_simple_method")
      } + 1])
    end

    def test_generate_method_without_exceptions_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#simple_method" do'
      # Should not include exception comments
      refute_match(/# Exceptions/, output.lines.grep(/describe "#simple_method"/).join("\n") + output.lines[output.lines.find_index { |l|
        l.include?('describe "#simple_method"')
      } + 1])
    end
    # rubocop:enable Metrics/AbcSize, Layout/LineLength
  end
end
