require 'thor'
require 'sonos'

module Sonos
  class Cli < Thor
    desc 'devices', 'Finds the IP address of all of the Sonos devices on your network'
    def devices
      system.devices.each do |device|
        puts device.name.ljust(20) + device.ip
      end
    end

    desc 'speakers', 'Finds the IP address of all of the Sonos speakers on your network'
    def speakers
      system.speakers.each do |speaker|
        puts speaker.name.ljust(20) + speaker.ip
      end
    end

    desc 'pause_all', 'Pauses all Sonos speaker groups'
    def pause_all
    	system.pause_all
    end

    desc 'play_all', 'Resumes playing all Sonos speaker groups'
    def play_all
      system.play_all
    end

    desc 'groups', 'List all Sonos groups'
    def groups
      system.groups.each do |group|
        puts group.master_speaker.name.ljust(20) + group.master_speaker.ip

        group.slave_speakers.each do |speaker|
          puts speaker.name.rjust(10).ljust(20) + speaker.ip
        end

        puts "\n"
      end
    end

    desc 'speaker [name] [command] [args]', 'Control a speaker'
    def speaker(name, command, *args)
      speakers = system.speakers.select { |s| s.name == name }
      puts "Could not find speaker" and return if speakers.length == 0

      speakers.each { |s| s.send command, *args }
    end

  private

    def system
      @system ||= Sonos::System.new
    end
  end
end
