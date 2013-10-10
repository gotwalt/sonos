require 'savon'
require 'sonos/endpoint'

module Sonos::Device

  # Used for PLAY:3, PLAY:5, PLAYBAR, SUB, CONNECT and CONNECT:AMP
  class Speaker < Base
    include Sonos::Endpoint::AVTransport
    include Sonos::Endpoint::Rendering
    include Sonos::Endpoint::Device
    include Sonos::Endpoint::ContentDirectory
    include Sonos::Endpoint::Upnp

    MODELS = {
      :'S3'    => 'PLAY:3',     # Released Jul 2011
      :'S5'    => 'PLAY:5',     # Released Nov 2009
      :'S9'    => 'PLAYBAR',    # Released Feb 2013
      :'Sub'   => 'SUB',        # Released May 2012
      :'ZP80'  => 'ZP80',       # Released Apr 2006
      :'ZP90'  => 'CONNECT',    # Released Aug 2008
      :'ZP100' => 'ZP100',      # Released Jan 2005
      :'ZP120' => 'CONNECT:AMP' # Released Aug 2008
    }.freeze

    def self.models
      MODELS
    end

    def speaker?
      true
    end
  end
end
