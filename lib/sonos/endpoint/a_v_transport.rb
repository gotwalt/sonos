require 'uri'

module Sonos::Endpoint::AVTransport
  TRANSPORT_ENDPOINT = '/MediaRenderer/AVTransport/Control'
  TRANSPORT_XMLNS = 'urn:schemas-upnp-org:service:AVTransport:1'

  # Get information about the currently playing track.
  # @return [Hash] information about the current track.
  def now_playing
    response = send_transport_message('GetPositionInfo')
    body = response.body[:get_position_info_response]
    doc = Nokogiri::XML(body[:track_meta_data])

    art_path = doc.xpath('//upnp:albumArtURI').inner_text

    # TODO: No idea why this is necessary. Maybe its a Nokogiri thing
    art_path.sub!('/getaa?s=1=x-sonos-http', '/getaa?s=1&u=x-sonos-http')

    {
      title: doc.xpath('//dc:title').inner_text,
      artist: doc.xpath('//dc:creator').inner_text,
      album: doc.xpath('//upnp:album').inner_text,
      queue_position: body[:track],
      track_duration: body[:track_duration],
      current_position: body[:rel_time],
      uri: body[:track_uri],
      album_art: "http://#{self.ip}:#{Sonos::PORT}#{art_path}"
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
    send_transport_message('SaveQueue', "<Title>#{title}</Title><ObjectID></ObjectID>")
  end

  # Join another speaker's group.
  # Trying to call this on a stereo pair slave will fail.
  def join(master)
    set_av_transport_uri('x-rincon:' + master.uid.sub('uuid:', ''))
  end

  # Add another speaker to this group.
  # Trying to call this on a stereo pair slave will fail.
  def group(slave)
    slave.join(self)
  end

  # Ungroup from its current group.
  # Trying to call this on a stereo pair slave will fail.
  def ungroup
    send_transport_message('BecomeCoordinatorOfStandaloneGroup')
  end

private

  # Play a stream.
  def set_av_transport_uri(uri)
    send_transport_message('SetAVTransportURI', "<CurrentURI>#{uri}</CurrentURI><CurrentURIMetaData></CurrentURIMetaData>")
  end

  def transport_client
    @transport_client ||= Savon.client endpoint: "http://#{self.ip}:#{Sonos::PORT}#{TRANSPORT_ENDPOINT}", namespace: Sonos::NAMESPACE
  end

  def send_transport_message(name, part = '<Speed>1</Speed>')
    action = "#{TRANSPORT_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{TRANSPORT_XMLNS}"><InstanceID>0</InstanceID>#{part}</u:#{name}>}
    transport_client.call(name, soap_action: action, message: message)
  end
end
