# frozen_string_literal: true

require_relative "base"

class Igata
  module Formatters
    class MinitestSpec < Base
      private

      def templates_dir
        File.join(__dir__, "templates", "minitest_spec")
      end
    end
  end
end
