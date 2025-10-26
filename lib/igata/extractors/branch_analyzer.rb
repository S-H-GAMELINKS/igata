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

      def extract_condition(branch_node) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return nil unless branch_node

        # Extract condition based on branch type
        condition_node = if branch_node.is_a?(Kanayago::IfStatementNode) || branch_node.is_a?(Kanayago::UnlessStatementNode)
                           branch_node.cond if branch_node.respond_to?(:cond)
                         elsif branch_node.is_a?(Kanayago::CaseNode)
                           branch_node.head if branch_node.respond_to?(:head)
                         end

        return nil unless condition_node

        extract_expression(condition_node)
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
        elsif node.is_a?(Kanayago::OperatorCallNode)
          # Handle comparison operators like age >= 18
          left = extract_expression(node.recv)
          operator = node.mid.to_s
          right = extract_expression(node.args&.val&.first)
          "#{left} #{operator} #{right}"
        elsif node.is_a?(Kanayago::CallNode)
          # Handle method calls like user.valid?
          if node.respond_to?(:recv) && node.recv
            receiver = extract_expression(node.recv)
            method_name = node.mid.to_s
            "#{receiver}.#{method_name}"
          elsif node.respond_to?(:mid)
            node.mid.to_s
          else
            "call"
          end
        elsif node.respond_to?(:mid)
          node.mid.to_s
        elsif node.is_a?(Integer) || node.is_a?(String)
          node.to_s
        else
          node.class.name.split("::").last.gsub("Node", "").downcase
        end
      end
    end
  end
end
