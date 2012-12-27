require 'open-uri'
require 'nokogiri'

module Sonos::Device
  class Base
    attr_reader :ip, :name, :uid, :serial_number, :software_version, :hardware_version, :mac_address, :group

    def self.detect(ip)
      data = retrieve_information(ip)
      model_number = data[:model_number]

      if Bridge.model_numbers.include?(model_number)
        Bridge.new(ip, data)
      elsif Speaker.model_numbers.include?(model_number)
        Speaker.new(ip, data)
      else
        raise ArgumentError.new("#{self.data[:model_number]} not supported")
      end
    end

    def initialize(ip, data = nil)
      @ip = ip

      if data.nil?
        self.data = Base.retrieve_information(ip)
      else
        self.data = data
      end
    end

    def data=(data)
      @name = data[:name]
      @uid = data[:uid]
      @serial_number = data[:serial_number]
      @software_version = data[:software_version]
      @hardware_version = data[:hardware_version]
      @zone_type = data[:zone_type]
      @model_number = data[:model_number]
    end

    def data
      {
        name: @name,
        uid: @uid,
        serial_number: @serial_number,
        software_version: @software_version,
        hardware_version: @hardware_version,
        zone_type: @zone_type,
        model_number: @model_number
      }
    end

    # Can this device play music?
    # @return [Boolean] a boolean indicating if it can play music
    def speaker?
      false
    end

  protected

    def self.retrieve_information(ip)
      url = "http://#{ip}:#{Sonos::PORT}/xml/device_description.xml"
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
