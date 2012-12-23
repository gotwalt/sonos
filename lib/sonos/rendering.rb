module Sonos
  module Rendering
    RENDERING_ENDPOINT = '/MediaRenderer/RenderingControl/Control'.freeze

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

    def rendering_client
      @rendering_client ||= Savon.client endpoint: "http://#{self.ip}:#{PORT}#{RENDERING_ENDPOINT}", namespace: NAMESPACE
    end
  end
end
