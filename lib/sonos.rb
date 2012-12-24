require 'sonos/version'
require 'sonos/speaker'
require 'sonos/discovery'

module Sonos
  PORT = 1400
  NAMESPACE = 'http://www.sonos.com/Services/1.1'

  def self.Speaker(ip)
    Speaker.new(ip)
  end

  def self.discover
    Sonos::Discovery.new.discover
  end
end
