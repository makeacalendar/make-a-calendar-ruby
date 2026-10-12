# frozen_string_literal: true

require "rake/testtask"
require "bundler/gem_tasks"

Rake::TestTask.new(:spec) do |task|
  task.libs << "lib"
  task.pattern = "spec/**/*_spec.rb"
end

task default: :spec
