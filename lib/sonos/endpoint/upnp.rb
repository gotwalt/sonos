require 'httpclient'

module Sonos::Endpoint::Upnp
  UPNP_TIMEOUT = 600

  ENDPOINT = {
    content_directory: '/MediaServer/ContentDirectory/Event',
    av_transport: '/MediaRenderer/AVTransport/Event',
    zone_group_topology: '/ZoneGroupTopology/Event',
    device_properties: '/DeviceProperties/Event',
    group_management: '/GroupManagement/Event'
  }.freeze

  # Subscribes to UPNP events, with callbacks being sent to the provided URL
  # @param [String] The URL to receive http callbacks from the device
  # @param [Symbol] The [Sonos::Endpoint::Upnp::ENDPOINT] to subscribe to
  # @return [Hash] Returns the timeout for the HTTP listener as well as the device SID
  def subscribe_to_upnp_events(callback_url, event)
    client = HTTPClient.new

    request_headers = {
      # The URL to be requested when a callback happens
      'CALLBACK' => "<#{callback_url}>",
      # Apparently required in order to appease the UPNP gods
      'NT' => 'upnp:event',
      # The timeout for the subscription - set to 10 minutes
      'Timeout' => "Seconds-#{UPNP_TIMEOUT}"
    }

    response = client.request(:subscribe, event_url(event), header: request_headers)

    # Convert the resulting headers into something less shouty
    result_headers = response.header.all.inject({}) do |result, item|
      result[item[0].downcase.to_sym] = item[1]
      result
    end

    # Return all the information you'd need in order to do an unsusbscribe
    Subscription.new({
      timeout: result_headers[:timeout][/(\d+)/].to_i,
      sid: result_headers[:sid],
      event: event
    })
  end

  # Unsubscribes an existing UPNP event
  # @param [String] The subscription ID that you wish to cancel
  # @param [Symbol] The [Sonos::Endpoint::Upnp::ENDPOINT] to which it belongs
  def unsubscribe_from_upnp_events(subscription)
    HTTPClient.new.request(:unsubscribe, event_url(subscription.event), header: {'SID' => subscription.sid })
  end

  # Simple class structure for describing an active subscription
  class Subscription
    attr_accessor :timeout
    attr_accessor :sid
    attr_accessor :event

    def initialize(hash)
      hash.each do |k, v|
        self.send("#{k}=", v) if respond_to?(k)
      end
    end
  end

  private

  def event_url(event)
    "http://#{self.ip}:#{Sonos::PORT}#{ENDPOINT[event]}"
  end

end
