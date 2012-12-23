require 'sonos/version'
require 'sonos/speaker'

module Sonos
  PORT = 1400.freeze
  NAMESPACE = 'http://www.sonos.com/Services/1.1'.freeze

  def self.Speaker(ip)
    Speaker.new(ip)
  end
end
