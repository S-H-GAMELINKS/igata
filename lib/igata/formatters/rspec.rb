# frozen_string_literal: true

require_relative "base"

class Igata
  module Formatters
    class RSpec < Base
      private

      def templates_dir
        File.join(__dir__, "templates", "rspec")
      end
    end
  end
end
