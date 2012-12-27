module Sonos
  # The Sonos system. The root object to manage the collection of groups and devices. This is
  # intended to be a singleton accessed from `Sonos.system`.
  class System
    attr_reader :topology
    attr_reader :groups
    attr_reader :devices

    # Initialize the system
    # @param [Array] the system topology. If this is nil, it will autodiscover.
    def initialize(topology = Sonos::Discovery.new.topology)
      @topology = topology
      construct_groups
    end

    # Returns all speakers
    def speakers
      @devices.select(&:speaker?)
    end

    # Pause all speakers
    def pause_all
      self.groups.each do |group|
        group.pause
      end
    end

  private

    def construct_groups
      # Reset
      @groups = []
      @devices = @topology.collect(&:device)

      # Loop through all of the unique groups
      @topology.collect(&:group).uniq.each do |group_uid|
        # Select all of the nodes with this group uid
        nodes = @topology.select do |node|
          node.group == group_uid
        end

        next if nodes.empty?

        # Find master node
        master_uuid = group_uid.split(':').first
        master = nodes.select do |node|
          node.uuid == master_uuid
        end

        next unless master.count == 1
        master = master.first

        nodes.delete(master)

        # Add the group
        @groups << Group.new(master.device, nodes.collect(&:device))
      end
    end
  end
end
