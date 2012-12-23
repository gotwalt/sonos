module Sonos
  module Transport
    TRANSPORT_ENDPOINT = '/MediaRenderer/AVTransport/Control'.freeze

    #
    # Get information about the currently playing track.
    #
    def get_position_info
      action = 'urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo'
      message = '<u:GetPositionInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Channel>Master</Channel></u:GetPositionInfo>'
      response = transport_client.call(:get_position_info, soap_action: action, message: message)
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
        album_art: "http://#{@ip}:#{PORT}#{doc.xpath('//upnp:albumArtURI').inner_text}"
      }
    end
    alias_method :now_playing, :get_position_info

    #
    # Pause the currently playing track.
    #
    def pause
      send_transport_message :pause
    end

    #
    # Play the currently selected track or play a stream.
    #
    def play(uri = nil)
      # Play a song from the uri
      if uri
        self.set_av_transport_uri(uri)
        return
      end

      # Play the currently selected track
      send_transport_message :play
    end

    #
    # Play a stream.
    #
    def set_av_transport_uri(uri)
      action = 'urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI'
      message = %Q{<u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><CurrentURI>#{uri}</CurrentURI><CurrentURIMetaData></CurrentURIMetaData></u:SetAVTransportURI>}
      transport_client.call(:set_av_transport_uri, soap_action: action, message: message)
      self.play
    end
    alias_method :play_stream, :set_av_transport_uri

    #
    # Stop playing.
    #
    def stop
      send_transport_message :stop
    end

    #
    # Play the next track.
    #
    def next
      send_transport_message :next
    end

    #
    # Play the previous track.
    #
    def previous
      send_transport_message :previous
    end

  private

    def transport_client
      @transport_client ||= Savon.client endpoint: "http://#{self.ip}:#{PORT}#{TRANSPORT_ENDPOINT}", namespace: NAMESPACE
    end

    def send_transport_message(sym)
      name = sym.to_s.split('_').map{|e| e.capitalize}.join
      action = "urn:schemas-upnp-org:service:AVTransport:1##{name}"
      message = %Q{<u:#{name} xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:#{name}>}
      transport_client.call(sym, soap_action: action, message: message)
    end
  end
end
