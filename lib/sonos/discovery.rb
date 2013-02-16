require 'socket'
require 'ipaddr'
require 'timeout'
require 'sonos/topology_node'

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
    DEFAULT_TIMEOUT = 1
    DEFAULT_IP = nil

    attr_reader :timeout
    attr_reader :first_device_ip
    attr_reader :default_ip

    def initialize(timeout = DEFAULT_TIMEOUT,default_ip = DEFAULT_IP)
      @timeout = timeout
      @default_ip = default_ip
      initialize_socket
    end

    # Look for Sonos devices on the network and return the first IP address found
    # @return [String] the IP address of the first Sonos device found
    def discover
      send_discovery_message
      @first_device_ip = listen_for_responses
    end

    # Find all of the Sonos devices on the network
    # @return [Array] an array of TopologyNode objects
    def topology
      self.discover unless @first_device_ip

      doc = Nokogiri::XML(open("http://#{@first_device_ip}:#{Sonos::PORT}/status/topology"))
      doc.xpath('//ZonePlayers/ZonePlayer').map do |node|
        TopologyNode.new(node)
      end
    end

  private

    def send_discovery_message
      # Request announcements
      @socket.send(search_message, 0, MULTICAST_ADDR, MULTICAST_PORT)
    end

    def listen_for_responses
      begin
        Timeout::timeout(timeout) do
          loop do
            message, info = @socket.recvfrom(2048)
            # return the IP address
            return info[2]
          end
        end
      rescue Timeout::Error => ex
        puts "Timeout error; switching to the default IP"
        return @default_ip
      end
    end

    def initialize_socket
      # Create a socket
      @socket = UDPSocket.open

      # We're going to use IP with the multicast TTL. Mystery third parameter is a mystery.
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 2)
    end

    def search_message
     [
        'M-SEARCH * HTTP/1.1',
        "HOST: #{MULTICAST_ADDR}:reservedSSDPport",
        'MAN: ssdp:discover',
        "MX: #{timeout}",
        "ST: urn:schemas-upnp-org:device:ZonePlayer:1"
      ].join("\n")
    end
  end
end
