require 'savon'
require 'sonos/transport'
require 'sonos/rendering'
require 'sonos/device'
require 'sonos/content_directory'

module Sonos
  class Speaker
    include Transport
    include Rendering
    include Device
    include ContentDirectory

    attr_reader :ip, :zone_name, :zone_icon, :uid, :serial_number, :software_version, :hardware_version, :mac_address

    def initialize(ip)
      @ip = ip

      # Get the speaker's status
      get_status
    end

    # URL for giant dump of device information
    def device_description_url
      "http://#{self.ip}:#{PORT}/xml/device_description.xml"
    end

  private

    # Get information about the speaker.
    def get_status
      doc = Nokogiri::XML(open("http://#{@ip}:1400/status/zp"))

      @zone_name = doc.xpath('.//ZoneName').inner_text
      @zone_icon = doc.xpath('.//ZoneIcon').inner_text
      @uid = doc.xpath('.//LocalUID').inner_text
      @serial_number = doc.xpath('.//SerialNumber').inner_text
      @software_version = doc.xpath('.//SoftwareVersion').inner_text
      @hardware_version = doc.xpath('.//HardwareVersion').inner_text
      @mac_address = doc.xpath('.//MACAddress').inner_text
      self
    end
  end
end
