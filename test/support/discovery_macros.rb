module DiscoveryMacros
  def stub_discovery
    Sonos::Discovery.any_instance.stubs(:initialize_socket)
    Sonos::Discovery.any_instance.stubs(:send_discovery_message)
    Sonos::Discovery.any_instance.stubs(:listen_for_responses).returns('10.0.1.10')
  end
end
