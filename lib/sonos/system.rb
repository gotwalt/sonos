module Sonos
  class System
    def pause_all
      # It looks like Sonos is just telling all of the groups to pause instead of
      # having a message to actually pause all
      self.groups.each do |group|
        group.pause
      end
    end

    def self.discover
      Sonos::Discovery.new.discover
    end
  end
end
