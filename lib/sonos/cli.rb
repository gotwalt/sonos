require 'thor'
require 'sonos'

module Sonos
  class Cli < Thor
    desc 'discover', 'Finds the IP address of a Sonos device on your network'
    def discover
      Sonos.discover.each do |node|
        puts node.inspect
      end
    end
  end
end
