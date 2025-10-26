# frozen_string_literal: true

require "kanayago"
require "erb"

require_relative "igata/version"
require_relative "igata/error"
require_relative "igata/values"
require_relative "igata/extractors/constant_path"
require_relative "igata/extractors/method_names"
require_relative "igata/extractors/branch_analyzer"
require_relative "igata/formatters/minitest"

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
    when Class
      formatter
    else
      raise Error, "Unknown formatter: #{formatter}"
    end
  end

  def find_target_class_node(constant_info)
    if constant_info.nested
      # When nested is true, recursively find the deepest (innermost) class
      # - class User; class Profile; end; end
      # - class App::User; class Profile; end; end (mixed pattern)
      # - class App::Model; class Admin::User; class Profile; end; end; end (3+ levels)
      find_deepest_class_node(@ast.body)
    else
      # When nested is false, @ast.body itself is the target
      # - class User
      # - class User::Profile
      @ast.body
    end
  end

  def find_deepest_class_node(parent_node)
    # Find direct child class/module under the current node
    direct_child = parent_node.body.body.find { |node| node.is_a?(Kanayago::ClassNode) || node.is_a?(Kanayago::ModuleNode) }
    return nil unless direct_child

    # Check if there's deeper nesting in the child node
    deeper_child = find_deepest_class_node(direct_child)

    # Return deeper nesting if exists, otherwise return current child
    deeper_child || direct_child
  end
end
