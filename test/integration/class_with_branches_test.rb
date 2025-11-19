# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithBranchesTest < Minitest::Test
    def test_generate_class_with_if_branch_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "class CalculatorTest < Minitest::Test"
      assert_includes output, "def test_check"
      assert_includes output, "# Branches: if"
    end

    def test_generate_class_with_if_branch_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, "RSpec.describe Calculator do"
      assert_includes output, 'describe "#check" do'
      assert_includes output, "# Branches: if"
    end

    def test_generate_class_with_unless_branch_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_validate"
      assert_includes output, "# Branches: unless"
    end

    def test_generate_class_with_unless_branch_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#validate" do'
      assert_includes output, "# Branches: unless"
    end

    def test_generate_class_with_case_branch_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_status"
      assert_includes output, "# Branches: case"
    end

    def test_generate_class_with_case_branch_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#status" do'
      assert_includes output, "# Branches: case"
    end

    def test_all_methods_included_with_minitest_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest)
      output = igata.generate

      assert_includes output, "def test_check"
      assert_includes output, "def test_validate"
      assert_includes output, "def test_status"
    end

    def test_all_methods_included_with_rspec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :rspec)
      output = igata.generate

      assert_includes output, 'describe "#check" do'
      assert_includes output, 'describe "#validate" do'
      assert_includes output, 'describe "#status" do'
    end

    def test_generate_class_with_if_branch_with_minitest_spec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest_spec)
      output = igata.generate

      assert_includes output, "describe Calculator do"
      assert_includes output, 'describe "#check" do'
      assert_includes output, "# Branches: if"
    end

    def test_generate_class_with_unless_branch_with_minitest_spec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest_spec)
      output = igata.generate

      assert_includes output, 'describe "#validate" do'
      assert_includes output, "# Branches: unless"
    end

    def test_generate_class_with_case_branch_with_minitest_spec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest_spec)
      output = igata.generate

      assert_includes output, 'describe "#status" do'
      assert_includes output, "# Branches: case"
    end

    def test_all_methods_included_with_minitest_spec_formatter
      source = File.read(File.expand_path("../fixtures/integration/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source, formatter: :minitest_spec)
      output = igata.generate

      assert_includes output, 'describe "#check" do'
      assert_includes output, 'describe "#validate" do'
      assert_includes output, 'describe "#status" do'
    end
  end
end
