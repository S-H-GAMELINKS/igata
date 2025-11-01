# frozen_string_literal: true

require "kanayago"
require "erb"

require_relative "igata/version"
require_relative "igata/error"
require_relative "igata/values"
require_relative "igata/extractors/constant_path"
require_relative "igata/extractors/method_names"
require_relative "igata/extractors/branch_analyzer"
require_relative "igata/extractors/comparison_analyzer"
require_relative "igata/formatters/minitest"
require_relative "igata/formatters/rspec"

class Igata
  def initialize(source, formatter: :minitest)
    @source = source
    @ast = Kanayago.parse(source)
    @formatter = formatter
  end

  def generate
    constant_info = Extractors::ConstantPath.extract(@ast)
    target_node = find_target_class_node(constant_info)
    method_infos = Extractors::MethodNames.extract(target_node)

    formatter_class = resolve_formatter(@formatter)
    formatter_class.new(constant_info, method_infos).generate
  end

  private

  def resolve_formatter(formatter)
    case formatter
    when :minitest
      Formatters::Minitest
    when :rspec
      Formatters::RSpec
    when Class
      formatter
    else
      raise Error, "Unknown formatter: #{formatter}"
    end
  end

  def find_target_class_node(constant_info)
    # First, find the actual ClassNode if @ast.body is a BlockNode
    root_class_node = find_root_class_node(@ast.body)

    if constant_info.nested
      # When nested is true, recursively find the deepest (innermost) class
      # - class User; class Profile; end; end
      # - class App::User; class Profile; end; end (mixed pattern)
      # - class App::Model; class Admin::User; class Profile; end; end; end (3+ levels)
      find_deepest_class_node(root_class_node)
    else
      # When nested is false, root_class_node itself is the target
      # - class User
      # - class User::Profile
      root_class_node
    end
  end

  def find_root_class_node(node)
    if node.is_a?(Kanayago::ClassNode) || node.is_a?(Kanayago::ModuleNode)
      node
    elsif node.is_a?(Kanayago::BlockNode) && node.respond_to?(:find)
      node.find { |n| n.is_a?(Kanayago::ClassNode) || n.is_a?(Kanayago::ModuleNode) }
    else
      node
    end
  end

  def find_deepest_class_node(parent_node) # rubocop:disable Metrics/CyclomaticComplexity
    # Find direct child class/module under the current node
    return nil unless parent_node.respond_to?(:body)
    return nil unless parent_node.body.respond_to?(:body)

    class_body = parent_node.body.body
    # For empty classes, class_body is BeginNode which doesn't have find
    return nil unless class_body.respond_to?(:find)

    direct_child = class_body.find { |node| node.is_a?(Kanayago::ClassNode) || node.is_a?(Kanayago::ModuleNode) }
    return nil unless direct_child

    # Check if there's deeper nesting in the child node
    deeper_child = find_deepest_class_node(direct_child)

    # Return deeper nesting if exists, otherwise return current child
    deeper_child || direct_child
  end
end
