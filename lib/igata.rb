# frozen_string_literal: true

require "kanayago"
require "erb"

require_relative "igata/version"
require_relative "igata/values"
require_relative "igata/extractors/constant_path"
require_relative "igata/extractors/method_names"

class Igata
  class Error < StandardError; end

  def initialize(source)
    @source = source
    @ast = Kanayago.parse(source)
  end

  def generate
    constant_info = Extractors::ConstantPath.extract(@ast)
    class_name = constant_info.path

    target_node = find_target_class_node(constant_info)
    method_infos = Extractors::MethodNames.extract(target_node)
    methods = generate_methods(method_infos)

    template = ERB.new(File.read("lib/igata/templates/class.erb"), trim_mode: "<>")
    template.result(binding)
  end

  private

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

  def generate_methods(method_infos)
    method_infos.map do |method_info|
      method_name = method_info.name
      ERB.new(File.read("lib/igata/templates/method.erb"), trim_mode: "<>").result(binding)
    end
  end
end
