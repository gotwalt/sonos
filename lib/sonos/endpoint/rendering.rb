module Sonos::Endpoint::Rendering
  RENDERING_ENDPOINT = '/MediaRenderer/RenderingControl/Control'
  RENDERING_XMLNS = 'urn:schemas-upnp-org:service:RenderingControl:1'

  # Get the current volume.
  # @return [Fixnum] the volume from 0 to 100
  def volume
    response = send_rendering_message('GetVolume')
    response.body[:get_volume_response][:current_volume].to_i
  end

  # Set the volume from 0 to 100.
  # @param [Fixnum] the desired volume from 0 to 100
  def volume=(value)
    send_rendering_message('SetVolume', value)
  end

  # Get the current bass EQ.
  # @return [Fixnum] the base EQ from -10 to 10
  def bass
    response = send_rendering_message('GetBass')
    response.body[:get_bass_response][:current_bass].to_i
  end

  # Set the bass EQ from -10 to 10.
  # @param [Fixnum] the desired bass EQ from -10 to 10
  def bass=(value)
    send_rendering_message('SetBass', value)
  end

  # Get the current treble EQ.
  # @return [Fixnum] the treble EQ from -10 to 10
  def treble
    response = send_rendering_message('GetTreble')
    response.body[:get_treble_response][:current_treble].to_i
  end

  # Set the treble EQ from -10 to 10.
  # @param [Fixnum] the desired treble EQ from -10 to 10
  def treble=(value)
    send_rendering_message('SetTreble', value)
  end

  # Mute the speaker
  def mute
    set_mute(true)
  end

  # Unmute the speaker
  def unmute
    set_mute(false)
  end

  # Is the speaker muted?
  # @return [Boolean] true if the speaker is muted and false if it is not
  def muted?
    response = send_rendering_message('GetMute')
    response.body[:get_mute_response][:current_mute] == '1'
  end

  # Get the loudness compenstation setting
  # @return [Boolean] true if the speaker has loudness on and false if it is not
  def loudness
    response = send_rendering_message('GetLoudness')
    response.body[:get_loudness_response][:current_loudness] == '1'
  end

  # Set the loudness compenstation setting
  # @param [Boolean] if the speaker has loudness on or not
  def loudness=(value)
    send_rendering_message('SetLoudness', value ? 1 : 0)
  end

private

  # Sets the speaker's mute
  # @param [Boolean] if the speaker is muted or not
  def set_mute(value)
    send_rendering_message('SetMute', value ? 1 : 0)
  end

  def rendering_client
    @rendering_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{RENDERING_ENDPOINT}", namespace: Sonos::NAMESPACE
  end

  def send_rendering_message(name, value = nil)
    action = "#{RENDERING_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{RENDERING_XMLNS}"><InstanceID>0</InstanceID><Channel>Master</Channel>}

    if value
      attribute = name.sub('Set', '')
      message += %Q{<Desired#{attribute}>#{value}</Desired#{attribute}></u:#{name}>}
    else
      message += %Q{</u:#{name}>}
    end

    rendering_client.call(name, soap_action: action, message: message)
  end
end
