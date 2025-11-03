# frozen_string_literal: true

class Igata
  module Extractors
    # rubocop:disable Metrics/ClassLength
    class ExceptionAnalyzer
      def self.extract(method_node)
        new(method_node).extract
      end

      def initialize(method_node)
        @method_node = method_node
      end

      def extract
        return [] unless @method_node
        return [] unless @method_node.respond_to?(:defn)

        exceptions = []
        # DefinitionNode has a defn field that contains ScopeNode
        defn_node = @method_node.defn
        traverse_node(defn_node, exceptions) if defn_node
        exceptions
      end

      private

      def traverse_node(node, exceptions) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        return unless node

        # Handle raise statement (FunctionCallNode with mid == :raise)
        if node.is_a?(Kanayago::FunctionCallNode) && node.respond_to?(:mid) && node.mid.to_s == "raise"
          exceptions << extract_raise_info(node)
        # Handle rescue clause
        elsif node.is_a?(Kanayago::RescueNode)
          extract_rescue_info(node, exceptions)
          # Continue traversing head (main body before rescue), rescue clause, and else
          if node.respond_to?(:head) && node.head
            if node.head.is_a?(Array)
              node.head.each { |child| traverse_node(child, exceptions) }
            else
              traverse_node(node.head, exceptions)
            end
          end
          traverse_node(node.resq, exceptions) if node.respond_to?(:resq)
          traverse_node(node.else, exceptions) if node.respond_to?(:else)
        # Handle RescueBody node (contains exception class list)
        elsif node.is_a?(Kanayago::RescueBodyNode)
          extract_rescue_body_info(node, exceptions)
          traverse_node(node.body, exceptions) if node.respond_to?(:body)
          traverse_node(node.next, exceptions) if node.respond_to?(:next)
        # Handle IfStatementNode (raise might be inside if)
        elsif node.is_a?(Kanayago::IfStatementNode)
          traverse_node(node.body, exceptions) if node.respond_to?(:body)
          traverse_node(node.elsif, exceptions) if node.respond_to?(:elsif)
          traverse_node(node.else, exceptions) if node.respond_to?(:else)
        # Handle UnlessStatementNode
        elsif node.is_a?(Kanayago::UnlessStatementNode)
          traverse_node(node.body, exceptions) if node.respond_to?(:body)
          traverse_node(node.else, exceptions) if node.respond_to?(:else)
        # Handle CaseNode
        elsif node.is_a?(Kanayago::CaseNode)
          traverse_node(node.body, exceptions) if node.respond_to?(:body)
          traverse_node(node.else, exceptions) if node.respond_to?(:else)
        # Handle ScopeNode (container node)
        elsif node.is_a?(Kanayago::ScopeNode)
          traverse_node(node.body, exceptions) if node.respond_to?(:body)
        # Handle BlockNode (container for multiple statements)
        elsif node.is_a?(Kanayago::BlockNode)
          node.each { |child| traverse_node(child, exceptions) } if node.respond_to?(:each)
        # Handle other container nodes
        elsif node.respond_to?(:body) && node.body.respond_to?(:each)
          node.body.each { |child| traverse_node(child, exceptions) }
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockNesting
      def extract_raise_info(call_node)
        # Extract exception class and message from raise statement
        # raise ArgumentError, "message" => args is ListNode with val array
        exception_class = "StandardError" # default
        message = nil

        if call_node.respond_to?(:args) && call_node.args
          args_node = call_node.args

          # ListNode contains exception class and message in val array
          if args_node.is_a?(Kanayago::ListNode) && args_node.respond_to?(:val)
            args_array = args_node.val

            if args_array.is_a?(Array)
              # First argument is exception class (if constant) or message (if string)
              first_arg = args_array[0]
              if first_arg
                if first_arg.is_a?(Kanayago::ConstantNode)
                  exception_class = first_arg.vid.to_s
                elsif first_arg.is_a?(Kanayago::StringNode)
                  # raise "message" - just a string message (StandardError)
                  message = first_arg.ptr
                end
              end

              # Second argument is message (if exists)
              second_arg = args_array[1]
              message = second_arg.ptr if second_arg.is_a?(Kanayago::StringNode)
            end
          end
        end

        context = build_raise_context(exception_class, message)
        Values::ExceptionInfo.new(
          type: :raise,
          exception_class: exception_class,
          message: message,
          context: context
        )
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/BlockNesting

      def extract_rescue_info(rescue_node, exceptions)
        # RescueNode might contain multiple rescue bodies
        # We'll handle this via RescueBodyNode traversal
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def extract_rescue_body_info(rescue_body_node, exceptions)
        # Extract exception class from rescue clause
        # rescue ArgumentError => e
        # rescue ArgumentError, StandardError => e
        exception_classes = []

        if rescue_body_node.respond_to?(:args) && rescue_body_node.args
          args_node = rescue_body_node.args

          # args is ListNode with val array containing exception classes
          if args_node.is_a?(Kanayago::ListNode) && args_node.respond_to?(:val)
            args_array = args_node.val

            if args_array.is_a?(Array)
              args_array.each do |arg|
                exception_classes << arg.vid.to_s if arg.is_a?(Kanayago::ConstantNode)
              end
            end
          end
        end

        # If no exceptions specified, it catches StandardError
        exception_classes = ["StandardError"] if exception_classes.empty?

        exception_classes.each do |exc_class|
          context = "rescue #{exc_class}"
          exceptions << Values::ExceptionInfo.new(
            type: :rescue,
            exception_class: exc_class,
            message: nil,
            context: context
          )
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      def build_raise_context(exception_class, message)
        if message
          "raise #{exception_class}, \"#{message}\""
        else
          "raise #{exception_class}"
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
