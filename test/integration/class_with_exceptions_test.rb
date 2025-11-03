# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithExceptionsTest < Minitest::Test
    def test_generate_class_with_exceptions
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "class PaymentProcessorTest < Minitest::Test"
      assert_includes output, "def test_process_payment"
      assert_includes output, "def test_validate_user"
      assert_includes output, "def test_simple_method"
    end

    def test_generate_method_with_raise
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_process_payment"
      assert_includes output, '# Exceptions raised: ArgumentError ("Invalid amount")'
    end

    def test_generate_method_with_rescue
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_process_payment"
      assert_includes output, "# Exceptions rescued: PaymentError"
    end

    def test_generate_method_with_multiple_raises
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_validate_user"
      assert_includes output, '# Exceptions raised: StandardError ("User is nil"), StandardError ("User not found")'
    end

    # rubocop:disable Metrics/AbcSize, Layout/LineLength
    def test_generate_method_without_exceptions
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_exceptions.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_simple_method"
      # Should not include exception comments
      refute_match(/# Exceptions/, output.lines.grep(/def test_simple_method/).join("\n") + output.lines[output.lines.find_index { |l|
        l.include?("def test_simple_method")
      } + 1])
    end
    # rubocop:enable Metrics/AbcSize, Layout/LineLength
  end
end
