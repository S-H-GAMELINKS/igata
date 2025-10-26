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
        # For empty classes, class_body is BeginNode which doesn't have filter_map
        return [] unless class_body.respond_to?(:filter_map)

        class_body.filter_map do |node|
          next unless node.is_a?(Kanayago::DefinitionNode)

          # Extract branch information for each method
          branches = BranchAnalyzer.extract(node)

          # Extract comparison information for each method
          comparisons = ComparisonAnalyzer.extract(node)

          Values::MethodInfo.new(name: node.mid.to_s, branches: branches, comparisons: comparisons)
        end
      end
    end
  end
end
