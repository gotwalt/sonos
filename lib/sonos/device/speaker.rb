require 'savon'
require 'sonos/endpoint'

# Used for PLAY:3, PLAY:5, and CONNECT
module Sonos::Device
  class Speaker < Base
    include Sonos::Endpoint::Transport
    include Sonos::Endpoint::Rendering
    include Sonos::Endpoint::Device
    include Sonos::Endpoint::ContentDirectory

    attr_reader :icon

  protected

    def parse_status(doc)
      super
      @icon = doc.xpath('.//ZoneIcon').inner_text
    end
  end
end
