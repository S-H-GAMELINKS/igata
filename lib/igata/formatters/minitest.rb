# frozen_string_literal: true

require_relative "base"

class Igata
  module Formatters
    class Minitest < Base
      private

      def templates_dir
        File.join(__dir__, "templates", "minitest")
      end
    end
  end
end
