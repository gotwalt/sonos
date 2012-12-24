require 'thor'
require 'sonos'

module Sonos
  class Cli < Thor
    desc 'discover', 'Finds the IP address of a Sonos device on your network'
    method_option :all, type: :boolean, aliases: '-a', desc: 'Find all of the IP address instead of the first one discovered'
    def discover
      speaker = Sonos.discover

      if options[:all]
        speaker.topology.each do |node|
          puts "#{node.name.ljust(20)} #{node.ip}"
        end
      else
        puts "#{speaker.zone_name.ljust(20)} #{speaker.ip}"
      end
    end
  end
end
