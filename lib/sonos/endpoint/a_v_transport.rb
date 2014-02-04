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

    # No music
    return nil if doc.children.length == 0

    art_path = doc.xpath('//upnp:albumArtURI').inner_text

    # TODO: No idea why this is necessary. Maybe its a Nokogiri thing
    art_path.sub!('/getaa?s=1=x-sonos-http', '/getaa?s=1&u=x-sonos-http')

    {
      title: doc.xpath('//dc:title').inner_text,
      artist: doc.xpath('//dc:creator').inner_text,
      album: doc.xpath('//upnp:album').inner_text,
      info: doc.xpath('//r:streamContent').inner_text,
      queue_position: body[:track],
      track_duration: body[:track_duration],
      current_position: body[:rel_time],
      uri: body[:track_uri],
      album_art: "http://#{self.ip}:#{Sonos::PORT}#{art_path}"
    }
  end

  def has_music?
    !now_playing.nil?
  end

  # Get information about the state the player is in.
  def get_player_state
    response = send_transport_message('GetTransportInfo')
    body = response.body[:get_transport_info_response]

    {
      status: body[:current_transport_status],
      state:  body[:current_transport_state],
      speed:  body[:current_speed],
    }
  end

  # Pause the currently playing track.
  def pause
    parse_response send_transport_message('Pause')
  end

  # Play the currently selected track or play a stream.
  # @param [String] uri Optional uri of the track to play. Leaving this blank, plays the current track.
  def play(uri = nil)
    # Play a song from the uri
    set_av_transport_uri(uri) and return if uri

    # Play the currently selected track
    parse_response send_transport_message('Play')
  end

  # Stop playing.
  def stop
    parse_response send_transport_message('Stop')
  end

  # Play the next track.
  def next
    parse_response send_transport_message('Next')
  end

  # Play the previous track.
  def previous
    parse_response send_transport_message('Previous')
  end
  
  def line_in(speaker)
    set_av_transport_uri('x-rincon-stream:' + speaker.uid.sub('uuid:', ''))
  end

  # Seeks to a given timestamp in the current track
  # @param [Fixnum] seconds
  def seek(seconds = 0)
    # Must be sent in the format of HH:MM:SS
    timestamp = Time.at(seconds).utc.strftime('%H:%M:%S')
    parse_response send_transport_message('Seek', "<Unit>REL_TIME</Unit><Target>#{timestamp}</Target>")
  end

  # Clear the queue
  def clear_queue
    parse_response parse_response send_transport_message('RemoveAllTracksFromQueue')
  end

  # Save queue
  def save_queue(title)
    parse_response send_transport_message('SaveQueue', "<Title>#{title}</Title><ObjectID></ObjectID>")
  end

  # Adds a track to the queue
  # @param[String] uri Uri of track
  # @param[String] didl Stanza of DIDL-Lite metadata (generally created by #add_spotify_to_queue)
  # @return[Integer] Queue position of the added track
  def add_to_queue(uri, didl = '')
    response = send_transport_message('AddURIToQueue', "<EnqueuedURI>#{uri}</EnqueuedURI><EnqueuedURIMetaData>#{didl}</EnqueuedURIMetaData><DesiredFirstTrackNumberEnqueued>0</DesiredFirstTrackNumberEnqueued><EnqueueAsNext>1</EnqueueAsNext>")
    # TODO yeah, this error handling is a bit soft. For consistency's sake :)
    pos = response.xpath('.//FirstTrackNumberEnqueued').text
    if pos.length != 0
      pos.to_i
    end
  end

  # Adds a Spotify track to the queue along with extra data for better metadata retrieval
  # @param[Hash] opts Various options (id, user, region and type)
  # @return[Integer] Queue position of the added track(s)
  def add_spotify_to_queue(opts = {})
    opts = {
      :id     => '',
      :user   => nil,
      :region => nil,
      :type   => 'track'
    }.merge(opts)

    # Basic validation of the accepted types; playlists need an associated user
    # and the toplist (for tracks and albums) need to specify a region.
    return nil if opts[:type] == 'playlist' and opts[:user].nil?
    return nil if opts[:type] =~ /toplist_tracks/ and opts[:region].nil?

    # In order for the player to retrieve track duration, artist, album etc
    # we need to pass it some metadata ourselves.
    didl_metadata = "&lt;DIDL-Lite xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot; xmlns:upnp=&quot;urn:schemas-upnp-org:metadata-1-0/upnp/&quot; xmlns:r=&quot;urn:schemas-rinconnetworks-com:metadata-1-0/&quot; xmlns=&quot;urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/&quot;&gt;&lt;item id=&quot;#{rand(10000000..99999999)}spotify%3a#{opts[:type]}%3a#{opts[:id]}&quot; restricted=&quot;true&quot;&gt;&lt;dc:title&gt;&lt;/dc:title&gt;&lt;upnp:class&gt;object.item.audioItem.musicTrack&lt;/upnp:class&gt;&lt;desc id=&quot;cdudn&quot; nameSpace=&quot;urn:schemas-rinconnetworks-com:metadata-1-0/&quot;&gt;SA_RINCON2311_X_#Svc2311-0-Token&lt;/desc&gt;&lt;/item&gt;&lt;/DIDL-Lite&gt;"

    r_id = rand(10000000..99999999)

    case opts[:type]
    when /playlist/
      uri = "x-rincon-cpcontainer:#{r_id}spotify%3auser%3a#{opts[:user]}%3aplaylist%3a#{opts[:id]}"
    when /toplist_(tracks)/
      subtype = opts[:type].sub('toplist_', '') # only 'tracks' are supported right now by Sonos.
      uri = "x-rincon-cpcontainer:#{r_id}toplist%2f#{subtype}%2fregion%2f#{opts[:region]}"
    when /album/
      uri = "x-rincon-cpcontainer:#{r_id}spotify%3aalbum%3a#{opts[:id]}"
    when /artist/
      uri = "x-rincon-cpcontainer:#{r_id}tophits%3aspotify%3aartist%3a#{opts[:id]}"
    when /starred/
      uri = "x-rincon-cpcontainer:#{r_id}starred"
    when /track/
      uri = "x-sonos-spotify:spotify%3a#{opts[:type]}%3a#{opts[:id]}"
    else
      return nil
    end

    add_to_queue(uri, didl_metadata)
   end

  # Removes a track from the queue
  # @param[String] object_id Track's queue ID
  def remove_from_queue(object_id)
    parse_response send_transport_message('RemoveTrackFromQueue', "<ObjectID>#{object_id}</ObjectID><UpdateID>0</UpdateID></u:RemoveTrackFromQueue>")
  end

  # Join another speaker's group.
  # Trying to call this on a stereo pair slave will fail.
  def join(master)
    parse_response set_av_transport_uri('x-rincon:' + master.uid.sub('uuid:', ''))
  end

  # Add another speaker to this group.
  # Trying to call this on a stereo pair slave will fail.
  def group(slave)
    slave.join(self)
  end

  # Ungroup from its current group.
  # Trying to call this on a stereo pair slave will fail.
  def ungroup
    parse_response send_transport_message('BecomeCoordinatorOfStandaloneGroup')
  end

  private

  # Play a stream.
  def set_av_transport_uri(uri)
    send_transport_message('SetAVTransportURI', "<CurrentURI>#{uri}</CurrentURI><CurrentURIMetaData></CurrentURIMetaData>")
  end

  def transport_client
    @transport_client ||= Savon.client endpoint: "http://#{self.group_master.ip}:#{Sonos::PORT}#{TRANSPORT_ENDPOINT}", namespace: Sonos::NAMESPACE, log: Sonos.logging_enabled
  end

  def send_transport_message(name, part = '<Speed>1</Speed>')
    action = "#{TRANSPORT_XMLNS}##{name}"
    message = %Q{<u:#{name} xmlns:u="#{TRANSPORT_XMLNS}"><InstanceID>0</InstanceID>#{part}</u:#{name}>}
    transport_client.call(name, soap_action: action, message: message)
  end
end
