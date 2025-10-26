# frozen_string_literal: true

class Igata
  module Extractors
    class ComparisonAnalyzer
      COMPARISON_OPERATORS = %i[>= <= > < == !=].freeze

      def self.extract(method_node)
        new(method_node).extract
      end

      def initialize(method_node)
        @method_node = method_node
      end

      def extract
        return [] unless @method_node
        return [] unless @method_node.respond_to?(:defn)

        comparisons = []
        # DefinitionNode has a defn field that contains ScopeNode
        defn_node = @method_node.defn
        traverse_node(defn_node, comparisons) if defn_node
        comparisons
      end

      private

      def traverse_node(node, comparisons) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        return unless node

        # Handle OperatorCallNode (comparison operators are OperatorCallNode in Kanayago)
        if node.is_a?(Kanayago::OperatorCallNode) && COMPARISON_OPERATORS.include?(node.mid)
          comparisons << Values::ComparisonInfo.new(
            operator: node.mid,
            left: extract_expression(node.recv),
            right: extract_expression(node.args&.val&.first),
            context: build_context(node)
          )
        # Handle AndNode and OrNode (traverse both sides)
        elsif node.is_a?(Kanayago::AndNode) || node.is_a?(Kanayago::OrNode)
          traverse_node(node.first, comparisons) if node.respond_to?(:first)
          traverse_node(node.second, comparisons) if node.respond_to?(:second)
        # Handle IfStatementNode (traverse condition and body)
        elsif node.is_a?(Kanayago::IfStatementNode)
          traverse_node(node.cond, comparisons) if node.respond_to?(:cond)
          traverse_node(node.body, comparisons) if node.respond_to?(:body)
          traverse_node(node.else, comparisons) if node.respond_to?(:else)
        # Handle UnlessStatementNode
        elsif node.is_a?(Kanayago::UnlessStatementNode)
          traverse_node(node.cond, comparisons) if node.respond_to?(:cond)
          traverse_node(node.body, comparisons) if node.respond_to?(:body)
          traverse_node(node.else, comparisons) if node.respond_to?(:else)
        # Handle CaseNode
        elsif node.is_a?(Kanayago::CaseNode)
          traverse_node(node.body, comparisons) if node.respond_to?(:body)
          traverse_node(node.else, comparisons) if node.respond_to?(:else)
        # Handle ScopeNode (container node)
        elsif node.is_a?(Kanayago::ScopeNode)
          traverse_node(node.body, comparisons) if node.respond_to?(:body)
        # Handle BlockNode (container for multiple statements)
        elsif node.is_a?(Kanayago::BlockNode)
          node.each { |child| traverse_node(child, comparisons) } if node.respond_to?(:each)
        # Handle other container nodes
        elsif node.respond_to?(:body) && node.body.respond_to?(:each)
          node.body.each { |child| traverse_node(child, comparisons) }
        end
      end

      def extract_expression(node) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        return "" unless node

        # Handle different node types for source reconstruction
        if node.is_a?(Kanayago::LocalVariableNode)
          node.vid.to_s
        elsif node.is_a?(Kanayago::InstanceVariableNode)
          node.vid.to_s
        elsif node.is_a?(Kanayago::IntegerNode)
          node.val.to_s
        elsif node.is_a?(Kanayago::StringNode)
          "\"#{node.val}\""
        elsif node.is_a?(Kanayago::SymbolNode)
          ":#{node.ptr}"
        elsif node.respond_to?(:mid)
          node.mid.to_s
        elsif node.is_a?(Integer) || node.is_a?(String)
          node.to_s
        else
          node.class.name.split("::").last.gsub("Node", "").downcase
        end
      end

      def build_context(call_node)
        left = extract_expression(call_node.recv)
        operator = call_node.mid.to_s
        right = extract_expression(call_node.args&.val&.first)
        "#{left} #{operator} #{right}"
      end
    end
  end
end
