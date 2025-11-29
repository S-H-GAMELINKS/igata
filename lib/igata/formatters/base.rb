# frozen_string_literal: true

require_relative "../error"

class Igata
  module Formatters
    class MethodNotOverriddenError < Igata::Error; end

    class Base
      def initialize(constant_info, method_infos)
        @constant_info = constant_info
        @method_infos = method_infos
      end

      def generate
        class_name = @constant_info.path
        methods = generate_methods

        template = ERB.new(File.read(template_path("class")), trim_mode: "<>")
        template.result(binding)
      end

      private

      def template_path(name)
        File.join(templates_dir, "#{name}.erb")
      end

      def templates_dir
        raise MethodNotOverriddenError, "#{self.class}#templates_dir must be implemented"
      end

      def render_template(template_file, binding_context)
        template_content = File.read(template_file)
        ERB.new(template_content, trim_mode: "<>").result(binding_context)
      end

      def generate_methods
        @method_infos.map do |method_info|
          method_name = method_info.name
          branches = method_info.branches
          comparisons = method_info.comparisons
          exceptions = method_info.exceptions
          boundary_values = method_info.boundary_values
          arguments = method_info.arguments
          ERB.new(File.read(template_path("method")), trim_mode: "<>").result(binding)
        end
      end
    end
  end
end
