require 'open-uri'
require 'nokogiri'

module Sonos::Device
  class Base
    attr_reader :ip, :name, :uid, :serial_number, :software_version, :hardware_version, :mac_address, :group
    attr_accessor :data

    PORT = 1400

    def initialize(ip, data = nil)
      @ip = ip
      @data = data
      if data.nil?
        self.data = Base.retrieve_information(ip)
      end
    end

    def self.detect(ip)
      data = retrieve_information(ip)
      if Bridge.model_numbers.include? data[:model_number]
        Bridge.new(ip, data)
      elsif Speaker.model_numbers.include? data[:model_number]
        Speaker.new(ip, data)
      else
        raise ArgumentError.new("#{data[:model_number]} not supported")
      end
    end

  protected

    def self.retrieve_information(ip)
      url = "http://#{ip}:#{PORT}/xml/device_description.xml"
      parse_description(Nokogiri::XML(open(url)))
    end

    # Get information about the device
    def self.parse_description(doc)
      {
        name: doc.xpath('/xmlns:root/xmlns:device/xmlns:roomName').inner_text,
        uid: doc.xpath('/xmlns:root/xmlns:device/xmlns:UDN').inner_text,
        serial_number: doc.xpath('/xmlns:root/xmlns:device/xmlns:serialNum').inner_text,
        software_version: doc.xpath('/xmlns:root/xmlns:device/xmlns:hardwareVersion').inner_text,
        hardware_version: doc.xpath('/xmlns:root/xmlns:device/xmlns:softwareVersion').inner_text,
        zone_type: doc.xpath('/xmlns:root/xmlns:device/xmlns:zoneType').inner_text,
        model_number: doc.xpath('/xmlns:root/xmlns:device/xmlns:modelNumber').inner_text
      }
    end
  end
end
