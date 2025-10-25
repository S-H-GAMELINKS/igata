# frozen_string_literal: true

class Igata
  module Extractors
    class MethodNames
      def self.extract(class_node)
        new(class_node).extract
      end

      def initialize(class_node)
        @class_node = class_node
      end

      def extract
        class_body = @class_node.body.body
        class_body.filter_map do |node|
          next unless node.is_a?(Kanayago::DefinitionNode)

          Values::MethodInfo.new(name: node.mid.to_s)
        end
      end
    end
  end
end
