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
      @topology = topology
      @groups = []
      @devices = @topology.collect(&:device)

      construct_groups
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

  private

    def send_to_all_speakers(action)
      if self.groups.length > 0
        self.groups.each { |group| group.send action }
      else
        self.speakers.each { |speaker| speaker.send action }
      end
    end

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
