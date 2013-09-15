require 'savon'
require 'sonos/endpoint'

module Sonos::Device

  # Used for PLAY:3, PLAY:5, and CONNECT
  class Speaker < Base
    include Sonos::Endpoint::AVTransport
    include Sonos::Endpoint::Rendering
    include Sonos::Endpoint::Device
    include Sonos::Endpoint::ContentDirectory

    MODEL_NUMBERS = ['S3', 'S5', 'S9', 'ZP90', 'Sub', 'ZP120']

    attr_reader :icon

    def self.model_numbers
      MODEL_NUMBERS
    end

    def speaker?
      true
    end
  end
end
