# frozen_string_literal: true

require_relative "base"

class Igata
  module Formatters
    class Minitest < Base
      def generate
        class_name = @constant_info.path
        methods = generate_methods

        template = ERB.new(File.read(template_path("class")), trim_mode: "<>")
        template.result(binding)
      end

      private

      def templates_dir
        File.join(__dir__, "templates", "minitest")
      end

      def generate_methods
        @method_infos.map do |method_info|
          method_name = method_info.name
          branches = method_info.branches
          # TODO: Support Comparison analysis
          # - Add Comparison analysis for expressions like: @age >= 18
          # - Template selection will be based on analysis results, not method name patterns
          ERB.new(File.read(template_path("method")), trim_mode: "<>").result(binding)
        end
      end
    end
  end
end
