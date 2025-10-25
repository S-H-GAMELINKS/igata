# frozen_string_literal: true

require "kanayago"
require "erb"

require_relative "igata/version"

class Igata
  class Error < StandardError; end

  def initialize(source)
    @source = source
    @ast = Kanayago.parse(source)
  end

  def generate
    class_name = extract_class
    methods = extract_methods

    template = ERB.new(File.read("lib/igata/templates/class.erb"), trim_mode: "<>")
    template.result(binding)
  end

  def extract_class
    @ast.body.cpath.mid.to_s
  end

  def extract_methods
    methods = @ast.body.body.body.filter_map { |node| node.mid.to_s if node.is_a?(Kanayago::DefinitionNode) }

    methods.map do |method_name|
      ERB.new(File.read("lib/igata/templates/method.erb"), trim_mode: "<>").result(binding)
    end
  end
end
