module Sonos
  # The Sonos system. The root object to manage the collection of groups and devices. This is
  # intended to be a singleton accessed from `Sonos.system`.
  class System
    attr_reader :topology
    attr_reader :groups
    attr_reader :devices

    # Initialize the system
    # @param [Array] the system topology. If this is nil, it will autodiscover.
    def initialize(topology = Discovery.new.topology)
      rescan topology
    end

    # Returns all speakers
    def speakers
      @devices.select(&:speaker?)
    end

    # Pause all speakers
    def pause_all
      speakers.each do |speaker|
        speaker.pause if speaker.has_music?
      end
    end

    # Play all speakers
    def play_all
      speakers.each do |speaker|
        speaker.play if speaker.has_music?
      end
    end

    # Party Mode!  Join all speakers into a single group.
    def party_mode new_master = nil
      return nil unless speakers.length > 1

      new_master = find_party_master if new_master.nil?

      party_over
      speakers.each do |slave|
        next if slave.uid == new_master.uid
        slave.join new_master
      end
      rescan @topology
    end

    def find_party_master
      # 1: If there are any pre-existing groups playing something, use
      # the lowest-numbered group's master
      groups.each do |group|
        return group.master_speaker if group.master_speaker.has_music?
      end

      # 2: Lowest-number speaker that's playing something
      speakers.each do |speaker|
        return speaker if speaker.has_music?
      end

      # 3: lowest-numbered speaker
      speakers[0]
    end
    
    # Party's over :(
    def party_over
      groups.each { |g| g.disband }
      rescan @topology
    end
    
    def rescan(topology = Discovery.new.topology)
      @topology = topology
      @groups = []
      @devices = @topology.collect(&:device)

      construct_groups
    end

  private

    def construct_groups
      # Loop through all of the unique groups
      @topology.collect(&:group).uniq.each do |group_uid|
        master_uuid = group_uid.split(':').first
        nodes = []
        master = nil

        @topology.each do |node|
          # Select all of the nodes with this group uid
          next unless node.group == group_uid

          if node.uuid == master_uuid
            master = node
          else
            nodes << node
          end
        end

        # Skip this group if there are no nodes or master
        next if nodes.empty? or master.nil?

        # Add the group
        @groups << Group.new(master.device, nodes.collect(&:device))
      end
    end
  end
end
