# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new(:spec) do |task|
  task.libs << "lib"
  task.pattern = "spec/**/*_spec.rb"
end

task default: :spec
