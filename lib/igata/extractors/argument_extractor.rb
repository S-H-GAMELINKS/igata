# frozen_string_literal: true

class Igata
  module Extractors
    # Extracts argument information from method definitions using script_lines
    class ArgumentExtractor
      def self.extract(method_info, script_lines)
        new(method_info, script_lines).extract
      end

      def initialize(method_info, script_lines)
        @method_info = method_info
        @script_lines = script_lines
      end

      def extract
        # Find the method definition line
        method_line = find_method_line(@method_info.name)
        return nil unless method_line

        # Parse arguments
        parse_arguments(method_line)
      end

      private

      def find_method_line(method_name)
        @script_lines.find do |line|
          line.strip.start_with?("def #{method_name}")
        end
      end

      def parse_arguments(method_line)
        # Extract arguments part from method definition
        if method_line =~ /def\s+\w+\s*\((.*?)\)/
          args_str = ::Regexp.last_match(1)
          parse_args_string(args_str)
        else
          # Method without parentheses (no arguments)
          Values::ArgumentInfo.new(args: [])
        end
      end

      def parse_args_string(args_str)
        return Values::ArgumentInfo.new(args: []) if args_str.strip.empty?

        args = args_str.split(",").map(&:strip).map do |arg|
          parse_single_arg(arg)
        end

        Values::ArgumentInfo.new(args: args)
      end

      # rubocop:disable Metrics/MethodLength
      def parse_single_arg(arg)
        case arg
        when /^(\w+)\s*=\s*(.+)$/ # Optional argument: name = "default"
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :optional,
            default: ::Regexp.last_match(2)
          )
        when /^(\w+):\s*(.+)$/ # Keyword argument: verified: false
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :keyword,
            default: ::Regexp.last_match(2)
          )
        when /^(\w+):$/ # Required keyword argument: verified:
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :required_keyword
          )
        when /^\*\*(\w+)$/ # Keyword rest: **kwargs
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :keyrest
          )
        when /^\*(\w+)$/ # Rest: *args
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :rest
          )
        when /^&(\w+)$/ # Block: &block
          Values::ArgDetail.new(
            name: ::Regexp.last_match(1),
            type: :block
          )
        else # Required argument: name
          Values::ArgDetail.new(
            name: arg,
            type: :required
          )
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
