require 'savon'
require 'sonos/endpoint'

module Sonos::Device

  # Used for non-speaker Sonos devices
  class Accessory < Base

    MODELS = {
      :'CR100' => 'CR100',   # Released Jan 2005
      :'CR200' => 'CONTROL', # Released Jul 2009
      :'WD100' => 'DOCK',
      :'ZB100' => 'BRIDGE'   # Released Oct 2007
    }.freeze

    def self.models
      MODELS
    end
  end
end
