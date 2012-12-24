module Sonos
  module Device
    DEVICE_ENDPOINT = '/DeviceProperties/Control'
    DEVICE_XMLNS = 'urn:schemas-upnp-org:service:DeviceProperties:1'

    # Turn the white status light on or off
    # @param [Boolean] True to turn on the light. False to turn off the light.
    def status_light_enabled=(enabled)
      send_device_message('SetLEDState', enabled ? 'On' : 'Off')
    end

  private

    def device_client
      @device_client ||= Savon.client endpoint: "http://#{self.ip}:#{PORT}#{DEVICE_ENDPOINT}", namespace: NAMESPACE
    end

    def send_device_message(name, value)
      action = "#{DEVICE_XMLNS}##{name}"
      attribute = name.sub('Set', '')
      message = %Q{<u:#{name} xmlns:u="#{DEVICE_XMLNS}"><Desired#{attribute}>#{value}</Desired#{attribute}>}
      device_client.call(name, soap_action: action, message: message)
    end
  end
end
