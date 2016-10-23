module Sonos::Endpoint::Device
  DEVICE_ENDPOINT = '/DeviceProperties/Control'
  DEVICE_XMLNS = 'urn:schemas-upnp-org:service:DeviceProperties:1'

  # Retrieve the status light state; true if on, false otherwise.
  def status_light_enabled?
    response = send_device_message('GetLEDState', '')
    body = response.body[:get_led_state_response]

    body[:current_led_state] == 'On' ? true : false
  end

  # Turn the white status light on or off
  # @param [Boolean] True to turn on the light. False to turn off the light.
  def status_light_enabled=(enabled)
    parse_response send_device_message('SetLEDState', enabled ? 'On' : 'Off')
  end

  def get_zone_info
    send_device_message('GetZoneInfo', '').body[:get_zone_info_response]
  end

  # Create a stereo pair of two speakers.
  # This does not take into account which type of players support bonding.
  # Currently only S1/S3 (play:1/play:3) support this but future players may
  # gain this abbility too. The speaker on which this method is called is
  # assumed to be the left speaker of the pair.
  # @param right [Sonos::Device::Speaker] Right speaker
  def create_pair_with(right)
    left = self.uid.sub!('uuid:', '')
    right = right.uid.sub!('uuid:', '')
    parse_response = send_bonding_message('AddBondedZones', "#{left}:LF,LF;#{right}:RF,RF")
  end

  def separate_pair
    parse_response = send_bonding_message('RemoveBondedZones', '')
  end

private

  def device_client
    @device_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{DEVICE_ENDPOINT}", namespace: Sonos::NAMESPACE, log: Sonos.logging_enabled
  end

  def send_device_message(name, value)
    action = "#{DEVICE_XMLNS}##{name}"
    attribute = name.sub('Set', '')
    message = %Q{<u:#{name} xmlns:u="#{DEVICE_XMLNS}"><Desired#{attribute}>#{value}</Desired#{attribute}>}
    device_client.call(name, soap_action: action, message: message)
  end

  def send_bonding_message(name, value)
    action = "#{DEVICE_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{DEVICE_XMLNS}"><ChannelMapSet>#{value}</ChannelMapSet></u:#{name}>}
    device_client.call(name, soap_action: action, message: message)
  end
end
