$: << File.dirname(__FILE__) + "/lib"

require "rspec/core/rake_task"

task :default => [ :spec ]

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

=begin
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end
=end
