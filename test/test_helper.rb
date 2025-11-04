# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  # minimum_coverage 90 # TODO: Phase 4完了後に90%に設定
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "igata"
require "debug"
require "minitest/autorun"
