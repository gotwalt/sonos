require 'savon'

module Sonos
  class Speaker
    TRANSPORT_ENDPOINT = '/MediaRenderer/AVTransport/Control'.freeze
    RENDERING_ENDPOINT = '/MediaRenderer/RenderingControl/Control'.freeze
    DEVICE_ENDPOINT = '/DeviceProperties/Control'.freeze

    attr_accessor :zone_name, :zone_icon, :uid, :serial_number, :software_version, :hardware_version, :mac_address

    def initialize(ip)
      @ip = ip

      # Get meta data
      self.get_speaker_info
    end

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

    #
    # Get information about the Sonos speaker.
    #
    def get_speaker_info
      doc = Nokogiri::XML(open("http://#{@ip}:1400/status/zp"))

      self.zone_name = doc.xpath('.//ZoneName').inner_text
      self.zone_icon = doc.xpath('.//ZoneIcon').inner_text
      self.uid = doc.xpath('.//LocalUID').inner_text
      self.serial_number = doc.xpath('.//SerialNumber').inner_text
      self.software_version = doc.xpath('.//SoftwareVersion').inner_text
      self.hardware_version = doc.xpath('.//HardwareVersion').inner_text
      self.mac_address = doc.xpath('.//MACAddress').inner_text
      self
    end

    #
    # Get the current volume.
    #
    def get_volume
      action = 'urn:schemas-upnp-org:service:RenderingControl:1#GetVolume'
      message = '<u:GetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel></u:GetVolume>'
      response = rendering_client.call(:get_volume, soap_action: action, message: message)
      response.body[:get_volume_response][:current_volume].to_i
    end
    alias_method :volume, :get_volume

    #
    # Set the volume from 0 to 100.
    #
    def set_volume(level)
      action = 'urn:schemas-upnp-org:service:RenderingControl:1#SetVolume'
      message = %Q{<u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel><DesiredVolume>#{level}</DesiredVolume></u:SetVolume>}
      rendering_client.call(:set_volume, soap_action: action, message: message)
    end
    alias_method :volume=, :set_volume

  private

    def transport_client
      @transport_client ||= Savon.client endpoint: "http://#{@ip}:#{PORT}#{TRANSPORT_ENDPOINT}", namespace: NAMESPACE
    end

    def rendering_client
      @rendering_client ||= Savon.client endpoint: "http://#{@ip}:#{PORT}#{RENDERING_ENDPOINT}", namespace: NAMESPACE
    end

    def send_transport_message(sym)
      name = sym.to_s.split('_').map{|e| e.capitalize}.join
      action = "urn:schemas-upnp-org:service:AVTransport:1##{name}"
      message = %Q{<u:#{name} xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:#{name}>}
      transport_client.call(sym, soap_action: action, message: message)
    end
  end
end
