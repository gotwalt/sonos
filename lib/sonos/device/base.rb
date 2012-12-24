require 'open-uri'
require 'nokogiri'

module Sonos::Device
  class Base
    attr_reader :ip, :name, :uid, :serial_number, :software_version, :hardware_version, :mac_address, :group

    def initialize(ip)
      @ip = ip

      # Get the speaker's status
      parse_status(Nokogiri::XML(open("http://#{@ip}:#{Sonos::PORT}/status/zp")))
    end

    # URL for giant dump of device information
    def device_description_url
      "http://#{self.ip}:#{PORT}/xml/device_description.xml"
    end

  protected

    # Get information about the speaker.
    def parse_status(doc)
      @name = doc.xpath('.//ZoneName').inner_text
      @uid = doc.xpath('.//LocalUID').inner_text
      @serial_number = doc.xpath('.//SerialNumber').inner_text
      @software_version = doc.xpath('.//SoftwareVersion').inner_text
      @hardware_version = doc.xpath('.//HardwareVersion').inner_text
      @mac_address = doc.xpath('.//MACAddress').inner_text
    end
  end
end
