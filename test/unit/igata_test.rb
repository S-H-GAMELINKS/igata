# frozen_string_literal: true

require "test_helper"

# rubocop:disable Metrics/ClassLength
class TestIgata < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Igata::VERSION
  end

  # ===== 初期化テスト =====

  def test_initialize_with_valid_source
    source = "class User; end"
    igata = Igata.new(source)
    assert_instance_of Igata, igata
  end

  def test_initialize_with_empty_source
    source = ""
    igata = Igata.new(source)
    assert_instance_of Igata, igata
  end

  def test_initialize_with_minitest_formatter
    source = "class User; end"
    igata = Igata.new(source, formatter: :minitest)
    assert_instance_of Igata, igata
  end

  def test_initialize_with_rspec_formatter
    source = "class User; end"
    igata = Igata.new(source, formatter: :rspec)
    assert_instance_of Igata, igata
  end

  def test_initialize_with_invalid_formatter
    source = "class User; end"
    error = assert_raises(Igata::Error) do
      Igata.new(source, formatter: :unknown).generate
    end
    assert_equal "Unknown formatter: unknown", error.message
  end

  def test_initialize_with_custom_formatter_class
    source = "class User; end"
    custom_formatter = Class.new(Igata::Formatters::Base) do
      def generate
        "custom test"
      end
    end
    igata = Igata.new(source, formatter: custom_formatter)
    assert_instance_of Igata, igata
  end

  # ===== generate メソッドテスト =====

  def test_generate_with_simple_class
    source = "class User; end"
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class UserTest")
  end

  def test_generate_with_simple_class_and_method
    source = <<~RUBY
      class User
        def name
          "test"
        end
      end
    RUBY
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class UserTest")
    assert result.include?("def test_name")
  end

  def test_generate_with_nested_class
    source = <<~RUBY
      class App
        class User
        end
      end
    RUBY
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class App::UserTest")
  end

  def test_generate_with_empty_class
    source = "class User; end"
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class UserTest")
  end

  def test_generate_with_rspec_formatter
    source = "class User; end"
    result = Igata.new(source, formatter: :rspec).generate
    assert result.include?("RSpec.describe User")
  end

  def test_generate_with_custom_formatter
    source = "class User; end"
    custom_formatter = Class.new(Igata::Formatters::Base) do
      def generate
        "# Custom test output"
      end
    end
    result = Igata.new(source, formatter: custom_formatter).generate
    assert_equal "# Custom test output", result
  end

  def test_generate_with_compact_nested_class
    source = "class App::User; end"
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class App::UserTest")
  end

  # ===== resolve_formatter メソッドテスト（間接的テスト） =====

  def test_resolve_formatter_with_minitest_symbol
    source = "class User; end"
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class UserTest")
    assert result.include?("< Minitest::Test")
  end

  def test_resolve_formatter_with_rspec_symbol
    source = "class User; end"
    result = Igata.new(source, formatter: :rspec).generate
    assert result.include?("RSpec.describe User")
  end

  def test_resolve_formatter_with_unknown_formatter_symbol
    source = "class User; end"
    error = assert_raises(Igata::Error) do
      Igata.new(source, formatter: :invalid).generate
    end
    assert_equal "Unknown formatter: invalid", error.message
  end

  def test_resolve_formatter_with_string_formatter
    source = "class User; end"
    error = assert_raises(Igata::Error) do
      Igata.new(source, formatter: "minitest").generate
    end
    assert_equal "Unknown formatter: minitest", error.message
  end

  # ===== find_target_class_node のエッジケーステスト（間接的テスト） =====

  def test_generate_with_deeply_nested_class
    source = <<~RUBY
      class A
        class B
          class C
          end
        end
      end
    RUBY
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class A::B::CTest")
  end

  def test_generate_with_mixed_nested_pattern
    source = <<~RUBY
      class App::Model
        class User
        end
      end
    RUBY
    result = Igata.new(source, formatter: :minitest).generate
    assert result.include?("class App::Model::UserTest")
  end
end
# rubocop:enable Metrics/ClassLength
