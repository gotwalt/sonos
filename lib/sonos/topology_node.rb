module Sonos
  class TopologyNode
    attr_accessor :name, :group, :coordinator, :location, :version, :uuid

    def initialize(node)
      node.attributes.each do |k, v|
        self.send("#{k}=", v.inner_text) if self.respond_to?(k.to_sym)
      end

      self.name = node.inner_text
    end

    def ip
      @ip ||= URI.parse(location).host
    end

    def device
      @device ||= Device::Base.detect(ip)
    end
  end
end
