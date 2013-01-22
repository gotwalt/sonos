require 'sonos/version'
require 'sonos/system'
require 'sonos/discovery'
require 'sonos/device'
require 'sonos/group'

module Sonos
  PORT = 1400
  NAMESPACE = 'http://www.sonos.com/Services/1.1'

  # # Create a new speaker with it's IP address
  # # @param [String] the speaker's IP address
  # def self.speaker(ip)
  #   Device::Speaker.new(ip)
  # end

  # # Get the Sonos system
  # def self.system
  #   @system ||= Sonos::System.new
  # end
end
