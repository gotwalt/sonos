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

    desc 'pause_all', 'Pause all speaker groups.'
    def pause_all
    	system.pause_all
    end

    desc 'play_all', 'Resume playing all speaker groups.'
    def play_all
      system.play_all
    end

    desc 'party_mode', 'Start a party! Put all speakers in the same group.'
    def party_mode
      system.party_mode
    end

    desc 'party_over', 'No more party :( Put all speakers in their own group.'
    def party_over
      system.party_over
    end

    desc 'groups', 'List all groups'
    def groups
      system.groups.each do |group|
        puts group.master_speaker.name.ljust(20) + group.master_speaker.ip

        group.slave_speakers.each do |speaker|
          puts speaker.name.rjust(10).ljust(20) + speaker.ip
        end

        puts "\n"
      end
    end

  private

    def system
      @system ||= Sonos::System.new
    end
  end
end
