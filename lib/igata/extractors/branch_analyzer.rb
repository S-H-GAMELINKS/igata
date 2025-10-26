# frozen_string_literal: true

class Igata
  module Extractors
    class BranchAnalyzer
      def self.extract(method_node)
        new(method_node).extract
      end

      def initialize(method_node)
        @method_node = method_node
      end

      def extract
        return [] unless @method_node
        return [] unless @method_node.respond_to?(:defn)

        branches = []
        # DefinitionNode has a defn field that contains ScopeNode
        defn_node = @method_node.defn
        traverse_node(defn_node, branches) if defn_node
        branches
      end

      private

      def traverse_node(node, branches) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        return unless node

        # Handle IfStatementNode (if/elsif/else)
        if node.is_a?(Kanayago::IfStatementNode)
          branches << Values::BranchInfo.new(
            type: :if,
            condition: extract_condition(node)
          )
          # Continue traversing child nodes
          traverse_node(node.body, branches) if node.respond_to?(:body)
          traverse_node(node.elsif, branches) if node.respond_to?(:elsif)
          traverse_node(node.else, branches) if node.respond_to?(:else)
        # Handle UnlessStatementNode
        elsif node.is_a?(Kanayago::UnlessStatementNode)
          branches << Values::BranchInfo.new(
            type: :unless,
            condition: extract_condition(node)
          )
          traverse_node(node.body, branches) if node.respond_to?(:body)
          traverse_node(node.else, branches) if node.respond_to?(:else)
        # Handle CaseNode (case/when)
        elsif node.is_a?(Kanayago::CaseNode)
          branches << Values::BranchInfo.new(
            type: :case,
            condition: extract_condition(node)
          )
          # Traverse when branches
          traverse_node(node.body, branches) if node.respond_to?(:body)
          traverse_node(node.else, branches) if node.respond_to?(:else)
        # Handle ScopeNode (container node)
        elsif node.is_a?(Kanayago::ScopeNode)
          traverse_node(node.body, branches) if node.respond_to?(:body)
        # Handle BlockNode (container for multiple statements)
        elsif node.is_a?(Kanayago::BlockNode)
          node.each { |child| traverse_node(child, branches) } if node.respond_to?(:each)
        # Handle other container nodes
        elsif node.respond_to?(:body) && node.body.respond_to?(:each)
          node.body.each { |child| traverse_node(child, branches) }
        end
      end

      def extract_condition(condition_node)
        return "" unless condition_node

        # For now, return a simple placeholder
        # In the future, we can implement proper source reconstruction
        condition_node.class.name.split("::").last.gsub("Node", "").downcase
      end
    end
  end
end
