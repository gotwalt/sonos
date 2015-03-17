require 'sonos/topology_node'
require 'ssdp'

#
# Inspired by https://github.com/rahims/SoCo, https://github.com/turboladen/upnp,
# and http://onestepback.org/index.cgi/Tech/Ruby/MulticastingInRuby.red.
#
# Turboladen's uPnP work is super-smart, but doesn't seem to work with 1.9.3 due to soap4r dep's.
#
# Some day this nonsense should be asynchronous / nonblocking / decorated with rainbows.
#

module Sonos
  class Discovery
    MULTICAST_ADDR = '239.255.255.250'
    MULTICAST_PORT = 1900
    DEFAULT_TIMEOUT = 2

    attr_reader :timeout
    attr_reader :first_device_ip
    attr_reader :default_ip

    def initialize(timeout = DEFAULT_TIMEOUT)
      @timeout = timeout
    end

    # Look for Sonos devices on the network and return the first IP address found
    # @return [String] the IP address of the first Sonos device found
    def discover
      result = SSDP::Consumer.new.search(service: 'urn:schemas-upnp-org:device:ZonePlayer:1', first_only: true, timeout: @timeout)
      @first_device_ip = result[:address]
    end

    # Find all of the Sonos devices on the network
    # @return [Array] an array of TopologyNode objects
    def topology
      self.discover unless @first_device_ip
      return [] unless @first_device_ip

      doc = Nokogiri::XML(open("http://#{@first_device_ip}:#{Sonos::PORT}/status/topology"))
      doc.xpath('//ZonePlayers/ZonePlayer').map do |node|
        TopologyNode.new(node)
      end
    end
  end
end
