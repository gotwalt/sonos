require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

desc "Open an irb session preloaded with this API"
task :console do
  $:.unshift(File.expand_path('../lib', __FILE__))
  require 'sonos'
  require 'irb'
  ARGV.clear
  IRB.start
end

task default: :test
