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

      speakers.each do |speaker|
        speaker.group_master = speaker
        @groups.each do |group|
          speaker.group_master = group.master_speaker if group.master_speaker.uid == speaker.uid
          group.slave_speakers.each do |slave|
            speaker.group_master = group.master_speaker if slave.uid == speaker.uid
          end
        end
      end
    end

  private

    def construct_groups
      # Loop through all of the unique groups
      @topology.collect(&:group).uniq.each do |group_uid|

        # set group's master nade using topology's coordinator parameter
        master = nil
        @topology.each do |node|
          # Select only the nodes with this group uid
          next unless node.group == group_uid
          master = node if node.coordinator == "true"
        end

        # register other nodes in groups as slave nodes
        nodes = []
        @topology.each do |node|
          # Select only the nodes with this group uid
          next unless node.group == group_uid
          nodes << node unless node.uuid == master.uuid
        end

        # Skip this group if there are no nodes or master
        next if master.nil?

        # Add the group
        @groups << Group.new(master.device, nodes.collect(&:device))
      end
    end
  end
end
