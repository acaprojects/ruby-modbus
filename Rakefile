require 'rubygems'
require 'rspec/core/rake_task'  # testing framework

task :default => :spec
RSpec::Core::RakeTask.new(:spec)

desc "Run all tests"
task :test => [:spec]
