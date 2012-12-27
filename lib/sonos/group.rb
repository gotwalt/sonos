module Sonos
  # Represents a Sonos group. A group can contain one or more speakers. All speakers in a group
  # play the same music in sync.
  class Group
    # The master speaker in the group
    attr_reader :master_speaker

    # All other speakers in the group
    attr_reader :slave_speakers

    def initialize(master_speaker, slave_speakers)
      @master_speaker = master_speaker
      @slave_speakers = (slave_speakers or [])
    end

    # All of the speakers in the group
    def speakers
      [self.master_speaker] + self.slave_speakers
    end

    # Remove all speakers from the group
    def disband
      self.slave_speakers.each do |speaker|
        speaker.ungroup
      end
    end

    # Full group name
    def name
      self.speakers.collect(&:name).uniq.join(', ')
    end

    # Forward AVTransport methods to the master speaker
    %w{now_playing pause stop next previous queue clear_queue}.each do |method|
      define_method(method) do
        self.master_speaker.send(method.to_sym)
      end
    end

    def play(uri = nil)
      self.master_speaker.play(uri)
    end

    def save_queue(name)
      self.master_speaker.save_queue(name)
    end
  end
end
