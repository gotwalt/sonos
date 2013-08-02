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

    desc 'speaker [name] [command] [args]', 'Control a speaker'
    def speaker(name, command, *args)
      speakers = system.speakers.select { |s| s.name.downcase == name.downcase }
      puts "Could not find speaker" and return if speakers.length == 0

      speakers.each { |s| s.send command, *args }
    end

    desc 'list_alarms', 'List all alarms.'
    def list_alarms
      puts speakers[0].list_alarms
    end

    desc 'is_alarm_enabled? [alarm_id]', 'Check if an alarm is enabled.'
    def is_alarm_enabled?(alarm_id)
      puts speakers[0].is_alarm_enabled?(alarm_id)
    end

    desc 'enable_alarm [alarm_id]', 'Enable an alarm.'
    def enable_alarm(alarm_id)
      speakers[0].enable_alarm(alarm_id)
    end

    desc 'disable_alarm [alarm_id]', 'Disable an alarm.'
    def disable_alarm(alarm_id)
      speakers[0].disable_alarm(alarm_id)
    end

    desc 'set_alarm_volume [alarm_id] [volume]', 'Set the volume for an alarm.'
    def set_alarm_volume(alarm_id, volume)
      speakers[0].set_alarm_volume(alarm_id, volume)
    end

    desc 'destroy_alarm [alarm_id]', 'Destroy an alarm.'
    def destroy_alarm(alarm_id)
      speakers[0].destroy_alarm(alarm_id)
    end

  private

    def system
      @system ||= Sonos::System.new
    end
  end
end
