# frozen_string_literal: true

class Igata
  module Extractors
    class ConstantPath # rubocop:disable Metrics/ClassLength
      def self.extract(ast)
        new(ast).extract
      end

      def initialize(ast)
        @ast = ast
        # If ast.body is BlockNode, find the ClassNode inside it
        @class_node = find_class_node(ast.body)
      end

      def find_class_node(node)
        if node.is_a?(Kanayago::ClassNode) || node.is_a?(Kanayago::ModuleNode)
          node
        elsif node.is_a?(Kanayago::BlockNode) && node.respond_to?(:find)
          node.find { |n| n.is_a?(Kanayago::ClassNode) || n.is_a?(Kanayago::ModuleNode) }
        else
          node
        end
      end

      def extract # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        if compact_nested? && nested?
          # Mixed pattern: class App::User; class Profile; end; end
          # Inner class may also be compact nested: class App::Model; class User::Profile; end
          # May be deeply nested: class App::Model; class Admin::User; class Profile; end; end; end
          compact_path = extract_compact_nested_path
          nested_path = build_nested_path(@class_node)
          path = "#{compact_path}::#{nested_path}"

          Values::ConstantPath.new(
            path: path,
            nested: true,  # Has nested class inside
            compact: true  # Outer is compact nested
          )
        elsif compact_nested?
          # Compact nested pattern (no inner nesting): class User::Profile
          path = extract_compact_nested_path
          Values::ConstantPath.new(
            path: path,
            nested: false, # No nested class inside
            compact: true
          )
        elsif nested?
          # Regular nested pattern: class User; class Profile; end; end
          # Inner class may also be compact nested: class User; class App::Profile; end
          # May be deeply nested: class User; class Admin::User; class Profile; end; end; end
          namespace = @class_node.cpath.mid.to_s
          nested_path = build_nested_path(@class_node)
          path = "#{namespace}::#{nested_path}"

          Values::ConstantPath.new(
            path: path,
            nested: true, # Has nested class inside
            compact: false
          )
        else
          # Simple pattern: class User
          Values::ConstantPath.new(
            path: @class_node.cpath.mid.to_s,
            nested: false,
            compact: false
          )
        end
      end

      private

      def compact_nested?
        # For compact nested pattern (class User::Profile), cpath is Colon2Node with non-nil head
        return false unless @class_node.respond_to?(:cpath)

        @class_node.cpath.is_a?(Kanayago::Colon2Node) && !@class_node.cpath.head.nil?
      end

      def extract_compact_nested_path
        # Recursively traverse cpath to build complete path
        build_constant_path(@class_node.cpath)
      end

      def build_constant_path(node) # rubocop:disable Metrics/MethodLength
        case node
        when Kanayago::Colon2Node
          if node.head.nil?
            # For "class User", head is nil so return only mid
            node.mid.to_s
          else
            # For "User::Profile", combine head(User) + mid(Profile)
            "#{build_constant_path(node.head)}::#{node.mid}"
          end
        when Kanayago::ConstantNode
          # Top-level constant name
          node.vid.to_s
        else
          node.to_s
        end
      end

      def nested?
        return false unless @class_node.respond_to?(:body)
        return false unless @class_node.body.respond_to?(:body)

        class_body = @class_node.body.body
        # For empty classes, class_body is BeginNode which doesn't have any?
        return false unless class_body.respond_to?(:any?)

        class_body.any? { |node| constant_definition_node?(node) }
      end

      def constant_definition_node?(node)
        node.is_a?(Kanayago::ClassNode) || node.is_a?(Kanayago::ModuleNode)
      end

      def build_nested_path(parent_node) # rubocop:disable Metrics/MethodLength
        # Find direct child class/module under the parent node
        class_body = parent_node.body.body
        # For empty classes, class_body is BeginNode which doesn't have find
        return nil unless class_body.respond_to?(:find)

        child_node = class_body.find { |node| constant_definition_node?(node) }
        return nil unless child_node

        # Get child class name (considering compact nesting)
        child_class_path = build_constant_path(child_node.cpath)

        # Check if there's deeper nesting
        deeper_path = build_nested_path(child_node)

        # Concatenate if deeper nesting exists, otherwise return current path
        if deeper_path
          "#{child_class_path}::#{deeper_path}"
        else
          child_class_path
        end
      end

      def find_nested_constant_node
        # Recursively find the deepest (innermost) class/module definition
        find_deepest_nested_constant_node(@class_node)
      end

      def find_deepest_nested_constant_node(parent_node)
        # Find direct child class/module under the current node
        direct_child = parent_node.body.body.find { |node| constant_definition_node?(node) }
        return nil unless direct_child

        # Check if there's deeper nesting in the child node
        deeper_child = find_deepest_nested_constant_node(direct_child)

        # Return deeper nesting if exists, otherwise return current child
        deeper_child || direct_child
      end
    end
  end
end
