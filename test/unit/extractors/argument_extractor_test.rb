# frozen_string_literal: true

require "test_helper"

class Igata
  module Extractors
    class ArgumentExtractorTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      def test_extract_no_arguments # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def simple
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "simple")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_instance_of Igata::Values::ArgumentInfo, result
        assert_equal 0, result.args.length
      end

      def test_extract_required_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def initialize(name, age)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "initialize")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 2, result.args.length
        assert_equal "name", result.args[0].name
        assert_equal :required, result.args[0].type
        assert_nil result.args[0].default
        assert_equal "age", result.args[1].name
        assert_equal :required, result.args[1].type
        assert_nil result.args[1].default
      end

      def test_extract_optional_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def greet(message = "Hello")
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "greet")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "message", result.args[0].name
        assert_equal :optional, result.args[0].type
        assert_equal '"Hello"', result.args[0].default
      end

      def test_extract_keyword_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def create(verified: false)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "create")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "verified", result.args[0].name
        assert_equal :keyword, result.args[0].type
        assert_equal "false", result.args[0].default
      end

      def test_extract_required_keyword_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def create(name:)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "create")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "name", result.args[0].name
        assert_equal :required_keyword, result.args[0].type
        assert_nil result.args[0].default
      end

      def test_extract_rest_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def process(*args)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "process")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "args", result.args[0].name
        assert_equal :rest, result.args[0].type
        assert_nil result.args[0].default
      end

      def test_extract_keyrest_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def process(**kwargs)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "process")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "kwargs", result.args[0].name
        assert_equal :keyrest, result.args[0].type
        assert_nil result.args[0].default
      end

      def test_extract_block_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def process(&block)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "process")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 1, result.args.length
        assert_equal "block", result.args[0].name
        assert_equal :block, result.args[0].type
        assert_nil result.args[0].default
      end

      def test_extract_mixed_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        code = <<~RUBY
          class User
            def complex(name, age = 18, verified: false, *args, **kwargs, &block)
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "complex")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_equal 6, result.args.length

        # Required argument
        assert_equal "name", result.args[0].name
        assert_equal :required, result.args[0].type

        # Optional argument
        assert_equal "age", result.args[1].name
        assert_equal :optional, result.args[1].type
        assert_equal "18", result.args[1].default

        # Keyword argument
        assert_equal "verified", result.args[2].name
        assert_equal :keyword, result.args[2].type
        assert_equal "false", result.args[2].default

        # Rest argument
        assert_equal "args", result.args[3].name
        assert_equal :rest, result.args[3].type

        # Keyrest argument
        assert_equal "kwargs", result.args[4].name
        assert_equal :keyrest, result.args[4].type

        # Block argument
        assert_equal "block", result.args[5].name
        assert_equal :block, result.args[5].type
      end

      def test_extract_method_not_found # rubocop:disable Metrics/MethodLength
        code = <<~RUBY
          class User
            def existing
            end
          end
        RUBY

        parse_result = Kanayago.parse(code)
        script_lines = parse_result.script_lines
        method_info = Igata::Values::MethodInfo.new(name: "nonexistent")
        result = Igata::Extractors::ArgumentExtractor.extract(method_info, script_lines)

        assert_nil result
      end
    end
  end
end
