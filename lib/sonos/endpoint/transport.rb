module Sonos::Endpoint::Transport
  TRANSPORT_ENDPOINT = '/MediaRenderer/AVTransport/Control'
  TRANSPORT_XMLNS = 'urn:schemas-upnp-org:service:AVTransport:1'

  # Get information about the currently playing track.
  # @return [Hash] information about the current track.
  def now_playing
    response = send_transport_message('GetPositionInfo')
    body = response.body[:get_position_info_response]
    doc = Nokogiri::XML(body[:track_meta_data])

    {
      title: doc.xpath('//dc:title').inner_text,
      artist: doc.xpath('//dc:creator').inner_text,
      album: doc.xpath('//upnp:album').inner_text,
      playlist_position: body[:track],
      track_duration: body[:track_duration],
      current_position: body[:rel_time],
      uri: body[:track_uri],
      album_art: "http://#{self.ip}:#{PORT}#{doc.xpath('//upnp:albumArtURI').inner_text}"
    }
  end

  # Pause the currently playing track.
  def pause
    send_transport_message('Pause')
  end

  # Play the currently selected track or play a stream.
  # @param [String] optional uri of the track to play. Leaving this blank, plays the current track.
  def play(uri = nil)
    # Play a song from the uri
    set_av_transport_uri(uri) and return if uri

    # Play the currently selected track
    send_transport_message('Play')
  end

  # Stop playing.
  def stop
    send_transport_message('Stop')
  end

  # Play the next track.
  def next
    send_transport_message('Next')
  end

  # Play the previous track.
  def previous
    send_transport_message('Previous')
  end

  # Clear the queue
  def clear_queue
    send_transport_message('RemoveAllTracksFromQueue')
  end

  # Save queue
  def save_queue(title)
    name = 'SaveQueue'
    action = "#{TRANSPORT_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{TRANSPORT_XMLNS}"><InstanceID>0</InstanceID><Title>#{title}</Title><ObjectID></ObjectID></u:#{name}>}
    transport_client.call(name, soap_action: action, message: message)
  end

private

  # Play a stream.
  def set_av_transport_uri(uri)
    name = 'SetAVTransportURI'
    action = "#{TRANSPORT_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{TRANSPORT_XMLNS}"><InstanceID>0</InstanceID><CurrentURI>#{uri}</CurrentURI><CurrentURIMetaData></CurrentURIMetaData></u:#{name}>}
    transport_client.call(name, soap_action: action, message: message)
    self.play
  end

  def transport_client
    @transport_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{TRANSPORT_ENDPOINT}", namespace: Sonos::NAMESPACE
  end

  def send_transport_message(name)
    action = "#{TRANSPORT_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{TRANSPORT_XMLNS}"><InstanceID>0</InstanceID><Speed>1</Speed></u:#{name}>}
    transport_client.call(name, soap_action: action, message: message)
  end
end
