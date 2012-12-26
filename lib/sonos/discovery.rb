require 'socket'
require 'ipaddr'
require 'timeout'

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

    attr_reader :timeout

    def initialize(timeout = nil)
      @timeout = timeout || DEFAULT_TIMEOUT

      initialize_socket
    end

    def discover
      send_discovery_message
      first_device_ip = listen_for_responses
      discover_topology(first_device_ip)
    end

  private

    def discover_topology(ip_address)
      doc = Nokogiri::XML(open("http://#{ip_address}:#{Sonos::PORT}/status/topology"))

      doc.xpath('//ZonePlayers/ZonePlayer').map do |node|
        TopologyNode.new(node).device
      end
    end

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
        nil
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

    class TopologyNode
      attr_accessor :name, :group, :coordinator, :location, :version, :uuid

      def initialize(node)
        node.attributes.each do |k, v|
          self.send("#{k}=", v) if self.respond_to?(k.to_sym)
        end

        self.name = node.inner_text
      end

      def ip
        @ip ||= URI.parse(location).host
      end

      def device
        @device || Sonos::Device::Base.detect(ip)
      end
    end
  end
end
