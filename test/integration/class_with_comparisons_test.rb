# frozen_string_literal: true

require "test_helper"

class Igata
  # rubocop:disable Metrics/ClassLength
  class ClassWithComparisonsTest < Minitest::Test
    def test_generate_class_with_greater_than_or_equal_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "class ValidatorTest < Minitest::Test"
      assert_includes output, "def test_adult?"
      assert_includes output, "# Comparisons: >= (age >= 18)"
    end

    def test_generate_class_with_greater_than_or_equal_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, "RSpec.describe Validator do"
      assert_includes output, 'describe "#adult?" do'
      assert_includes output, "# Comparisons: >= (age >= 18)"
    end

    def test_generate_class_with_less_than_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_minor?"
      assert_includes output, "# Comparisons: < (age < 18)"
    end

    def test_generate_class_with_less_than_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#minor?" do'
      assert_includes output, "# Comparisons: < (age < 18)"
    end

    def test_generate_class_with_equal_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_equal_check"
      assert_includes output, "# Comparisons: == (value == 100)"
    end

    def test_generate_class_with_equal_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#equal_check" do'
      assert_includes output, "# Comparisons: == (value == 100)"
    end

    def test_generate_class_with_multiple_comparisons_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_valid_range?"
      assert_includes output, "# Comparisons: >= (value >= 0), <= (value <= 150)"
    end

    def test_generate_class_with_multiple_comparisons_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#valid_range?" do'
      assert_includes output, "# Comparisons: >= (value >= 0), <= (value <= 150)"
    end

    def test_generate_class_with_comparison_in_if_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_check_status"
      assert_includes output, "# Branches: if"
      assert_includes output, "# Comparisons: > (score > 80)"
    end

    def test_generate_class_with_comparison_in_if_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#check_status" do'
      assert_includes output, "# Branches: if"
      assert_includes output, "# Comparisons: > (score > 80)"
    end

    def test_all_methods_included_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_adult?"
      assert_includes output, "def test_minor?"
      assert_includes output, "def test_equal_check"
      assert_includes output, "def test_valid_range?"
      assert_includes output, "def test_check_status"
    end

    def test_all_methods_included_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_comparisons.rb",
                                          __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#adult?" do'
      assert_includes output, 'describe "#minor?" do'
      assert_includes output, 'describe "#equal_check" do'
      assert_includes output, 'describe "#valid_range?" do'
      assert_includes output, 'describe "#check_status" do'
    end
  end
  # rubocop:enable Metrics/ClassLength
end
