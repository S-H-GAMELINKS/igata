# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithComparisonsTest < Minitest::Test
    def test_generate_class_with_greater_than_or_equal
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "class ValidatorTest < Minitest::Test"
      assert_includes output, "def test_adult?"
      assert_includes output, "# Comparisons: >= (age >= 18)"
    end

    def test_generate_class_with_less_than
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_minor?"
      assert_includes output, "# Comparisons: < (age < 18)"
    end

    def test_generate_class_with_equal
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_equal_check"
      assert_includes output, "# Comparisons: == (value == 100)"
    end

    def test_generate_class_with_multiple_comparisons
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_valid_range?"
      assert_includes output, "# Comparisons: >= (value >= 0), <= (value <= 150)"
    end

    def test_generate_class_with_comparison_in_if
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_check_status"
      assert_includes output, "# Branches: if"
      assert_includes output, "# Comparisons: > (score > 80)"
    end

    def test_all_methods_included
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_adult?"
      assert_includes output, "def test_minor?"
      assert_includes output, "def test_equal_check"
      assert_includes output, "def test_valid_range?"
      assert_includes output, "def test_check_status"
    end
  end
end
