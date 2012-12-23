require 'savon'
require 'sonos/transport'
require 'sonos/rendering'
require 'sonos/device'

module Sonos
  class Speaker
    include Transport
    include Rendering
    include Device

    attr_accessor :zone_name, :zone_icon, :uid, :serial_number, :software_version, :hardware_version, :mac_address
    attr_reader :ip

    def initialize(ip)
      @ip = ip

      # Get meta data
      self.get_speaker_info
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
  end
end
