# frozen_string_literal: true

require "test_helper"
require "open3"
require "tempfile"

class CliTest < Minitest::Test
  def setup
    @cli_path = File.expand_path("../../exe/igata", __dir__)
    @fixture_path = File.expand_path("../fixtures/integration/minitest/sources/basic_class.rb", __dir__)
  end

  def test_file_argument_execution
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, @fixture_path)

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "class UserTest < Minitest::Test"
    assert_includes stdout, "def test_initialize"
    assert_includes stdout, "def test_adult?"
    assert_includes stdout, "def test_greeting"
  end

  def test_stdin_input
    source = File.read(@fixture_path)
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, stdin_data: source)

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "class UserTest < Minitest::Test"
    assert_includes stdout, "def test_initialize"
  end

  def test_output_option # rubocop:disable Metrics/MethodLength
    Tempfile.create(["igata_test", ".rb"]) do |tmpfile|
      stdout, stderr, status = Open3.capture3(
        "bundle", "exec", @cli_path, @fixture_path, "-o", tmpfile.path
      )

      assert_equal 0, status.exitstatus
      assert_empty stderr
      assert_empty stdout # Output goes to file, not stdout

      output = File.read(tmpfile.path)
      assert_includes output, "class UserTest < Minitest::Test"
      assert_includes output, "def test_initialize"
    end
  end

  def test_formatter_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, @fixture_path, "-f", "minitest")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "class UserTest < Minitest::Test"
    assert_includes stdout, "def test_initialize"
  end

  def test_long_formatter_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, @fixture_path, "--formatter", "minitest")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "class UserTest < Minitest::Test"
    assert_includes stdout, "def test_initialize"
  end

  def test_rspec_formatter_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, @fixture_path, "-f", "rspec")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "RSpec.describe User do"
    assert_includes stdout, "describe \"#initialize\" do"
    assert_includes stdout, "it \"works correctly\" do"
  end

  def test_long_rspec_formatter_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, @fixture_path, "--formatter", "rspec")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "RSpec.describe User do"
    assert_includes stdout, "describe \"#initialize\" do"
  end

  def test_help_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, "--help")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "Usage: igata [options] [file]"
    assert_includes stdout, "-f, --formatter FORMATTER"
    assert_includes stdout, "-o, --output FILE"
    assert_includes stdout, "-h, --help"
    assert_includes stdout, "-v, --version"
  end

  def test_version_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, "--version")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_equal "0.2.0\n", stdout
  end

  def test_short_help_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, "-h")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_includes stdout, "Usage: igata [options] [file]"
  end

  def test_short_version_option
    stdout, stderr, status = Open3.capture3("bundle", "exec", @cli_path, "-v")

    assert_equal 0, status.exitstatus
    assert_empty stderr
    assert_equal "0.2.0\n", stdout
  end
end
