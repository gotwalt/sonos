require 'uri'

module Sonos
  module Topology

    def topology
      doc = Nokogiri::XML(open("http://#{@ip}:1400/status/topology"))

      doc.xpath('//ZonePlayers/ZonePlayer').map do |node|
        Node.new(node)
      end
    end

    protected

    class Node
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
    end
  end
end
