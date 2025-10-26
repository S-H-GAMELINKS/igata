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
        raise MethodNotOverriddenError, "#{self.class}#generate must be implemented"
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
    end
  end
end
