# frozen_string_literal: true

require "test_helper"

class Igata
  class ClassWithBranchesTest < Minitest::Test
    def test_generate_class_with_if_branch
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "class CalculatorTest < Minitest::Test"
      assert_includes output, "def test_check"
      assert_includes output, "# Branches: if"
    end

    def test_generate_class_with_unless_branch
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_validate"
      assert_includes output, "# Branches: unless"
    end

    def test_generate_class_with_case_branch
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_status"
      assert_includes output, "# Branches: case"
    end

    def test_all_methods_included
      source = File.read(File.expand_path("../fixtures/integration/minitest/sources/class_with_branches.rb", __dir__))
      igata = Igata.new(source)
      output = igata.generate

      assert_includes output, "def test_check"
      assert_includes output, "def test_validate"
      assert_includes output, "def test_status"
    end
  end
end
