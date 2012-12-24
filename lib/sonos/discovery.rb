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

    PLAYER_SEARCH = "M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:reservedSSDPport
MAN: ssdp:discover
MX: 1
ST: urn:schemas-upnp-org:device:ZonePlayer:1"

    MULTICAST_ADDR = "239.255.255.250"
    MULTICAST_PORT = 1900

    SEARCH_TIMEOUT = 1

    def initialize
      initialize_socket
    end

    def discover(timeout = nil)
      send_discovery_message
      listen_for_responses( timeout ||= SEARCH_TIMEOUT)
    end

    def discover_multiple(timeout = nil)
      send_discovery_message
      listen_for_multiple_responses( timeout ||= SEARCH_TIMEOUT)
    end

    def send_discovery_message
      # request announcements
      @socket.send(PLAYER_SEARCH, 0, MULTICAST_ADDR, MULTICAST_PORT)
    end

    def listen_for_responses(timeout)
      begin
        Timeout::timeout(timeout) do
          loop do
            message, info = @socket.recvfrom(2048)
            # return the IP address
            return info[2]
          end
        end
      rescue Timeout::Error => ex
        raise SonosNotFoundError.new
      end
    end

    def listen_for_multiple_responses(timeout)
      results = []

      begin
        Timeout::timeout(timeout) do
          loop do
            message, info = @socket.recvfrom(2048)
            # return the IP address
            results << info[2]
          end
        end
      rescue Timeout::Error => ex
        # this one's expected, as we're just hanging out and trying to find stuff
      end

      results
    end

    def initialize_socket
      # create a socket
      @socket = UDPSocket.open

      # we're going to use IP with the multicast TTL. Mystery third parameter is a mystery.
      @socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 2)
    end

    class SonosNotFoundError < StandardError; end
  end
end
