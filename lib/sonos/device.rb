module Sonos
  module Device
    DEVICE_ENDPOINT = '/DeviceProperties/Control'.freeze

  private

    def device_client
      @device_client ||= Savon.client endpoint: "http://#{self.ip}:#{PORT}#{DEVICE_ENDPOINT}", namespace: NAMESPACE
    end
  end
end
