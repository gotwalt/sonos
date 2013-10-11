require 'httpclient'

module Sonos::Endpoint::Upnp
  TIMEOUT = 600

  # Subscribes to UPNP events, with callbacks being sent to the provided URL
  # @param [String] The URL to receive http callbacks from the device
  # @return [Hash] Returns the timeout for the HTTP listener as well as the device SID
  def subscribe_to_upnp_events(callback_url)
    client = HTTPClient.new
    response = client.request(:subscribe, event_uri, header: {'CALLBACK' => "<#{callback_url}>", 'NT' => 'upnp:event', 'Timeout' => "Seconds-#{TIMEOUT}"})
    headers = response.header.all.inject({}) do |result, item|
      result[item[0].downcase.to_sym] = item[1]
      result
    end

    {
      timeout: headers[:timeout][/(\d+)/].to_i,
      sid: headers[:sid]
    }
  end

  def unsubscribe_from_upnp_events(sid)
    HTTPClient.new.request(:subscribe, event_uri, header: {'SID' => sid })
  end

  private

  def event_uri
    "http://#{self.ip}:#{Sonos::PORT}/MediaServer/ContentDirectory/Event"
  end

end
