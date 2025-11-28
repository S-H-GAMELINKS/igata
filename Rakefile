# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "fileutils"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

INTEGRATION_TEST_TARGET_REPOS_DIR = File.expand_path("tmp/integration_repos", __dir__)
INTEGRATION_TEST_TARGET_REPOSITORIES = {
  "rails" => {
    url: "https://github.com/rails/rails.git",
    branch: "main",
    depth: 1
  },
  "discourse" => {
    url: "https://github.com/discourse/discourse.git",
    branch: "main",
    depth: 1
  },
  "mastodon" => {
    url: "https://github.com/mastodon/mastodon.git",
    branch: "main",
    depth: 1
  },
  "gitlab" => {
    url: "https://gitlab.com/gitlab-org/gitlab.git",
    branch: "master",
    depth: 1
  }
}.freeze

namespace :integration do # rubocop:disable Metrics/BlockLength
  desc "Setup integration test repositories"
  task :setup do
    FileUtils.mkdir_p(INTEGRATION_TEST_TARGET_REPOS_DIR)

    INTEGRATION_TEST_TARGET_REPOSITORIES.each do |name, config|
      repo_path = File.join(INTEGRATION_TEST_TARGET_REPOS_DIR, name)

      if File.directory?(repo_path)
        puts "Repository #{name} already exists at #{repo_path}"
        next
      end

      puts "Cloning #{name} from #{config[:url]}..."
      system("git clone --depth #{config[:depth]} --branch #{config[:branch]} #{config[:url]} #{repo_path}")

      if $?.success? # rubocop:disable Style/SpecialGlobalVars
        puts "Successfully cloned #{name}"
      else
        puts "Failed to clone #{name}"
      end
    end

    puts "\nIntegration test repositories setup complete!"
  end

  desc "Clean integration test repositories"
  task :clean do
    if File.directory?(INTEGRATION_TEST_TARGET_REPOS_DIR)
      puts "Removing integration test repositories at #{INTEGRATION_TEST_TARGET_REPOS_DIR}..."
      FileUtils.rm_rf(INTEGRATION_TEST_TARGET_REPOS_DIR)
      puts "Done!"
    else
      puts "No integration test repositories found"
    end
  end

  desc "Update integration test repositories"
  task :update do
    unless File.directory?(INTEGRATION_TEST_TARGET_REPOS_DIR)
      puts "No repositories found. Run 'rake integration:setup' first."
      next
    end

    INTEGRATION_TEST_TARGET_REPOSITORIES.each_key do |name|
      repo_path = File.join(INTEGRATION_TEST_TARGET_REPOS_DIR, name)

      unless File.directory?(repo_path)
        puts "Repository #{name} not found, skipping..."
        next
      end

      puts "Updating #{name}..."
      Dir.chdir(repo_path) do
        system("git pull")
      end
    end

    puts "\nIntegration test repositories updated!"
  end

  desc "Run integration tests against real-world repositories"
  task test: :setup do # rubocop:disable Metrics/BlockLength
    require_relative "lib/igata"

    success = true

    INTEGRATION_TEST_TARGET_REPOSITORIES.each_key do |name| # rubocop:disable Metrics/BlockLength
      repo_path = File.join(INTEGRATION_TEST_TARGET_REPOS_DIR, name)

      unless File.directory?(repo_path)
        puts "Repository #{name} not found, skipping..."
        next
      end

      puts "\n#{"=" * 60}"
      puts "Testing #{name}..."
      puts "=" * 60

      ruby_files = Dir.glob(File.join(repo_path, "**", "*.rb"))
      puts "Found #{ruby_files.size} Ruby files"

      failed_files = []
      ruby_files.each_with_index do |file, index|
        print "\r  Processing #{index + 1}/#{ruby_files.size}: #{File.basename(file)}".ljust(80)

        begin
          source = File.read(file)
          Igata.new(source).generate
        rescue StandardError => e
          failed_files << { file: file, error: e.message }
        end
      end

      puts "\n  Completed: #{ruby_files.size - failed_files.size}/#{ruby_files.size} files passed"

      next if failed_files.empty?

      puts "  Failed files:"
      failed_files.first(10).each do |f|
        puts "    - #{f[:file]}: #{f[:error]}"
      end
      puts "    ... and #{failed_files.size - 10} more" if failed_files.size > 10
      success = false
    end

    exit(1) unless success
  end
end
