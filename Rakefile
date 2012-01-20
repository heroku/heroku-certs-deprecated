$: << File.dirname(__FILE__) + "/lib"

require "rspec/core/rake_task"

task :default => [ :spec ]

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

task :deploy do
  `mkdir -p $HOME/.heroku/plugins/heroku-certs \
    && rm -rf $HOME/.heroku/plugins/heroku-certs/* \
    && cp -r * $HOME/.heroku/plugins/heroku-certs/`
end
