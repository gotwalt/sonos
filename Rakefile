require 'bundler/gem_tasks'

desc "Open an irb session preloaded with this API"
task :console do
  $:.unshift(File.expand_path('../lib', __FILE__))
  require 'sonos'
  require 'irb'
  ARGV.clear
  IRB.start
end
