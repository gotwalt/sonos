require 'open-uri'
require 'nokogiri'

module Sonos::Device
  class Base
    attr_reader :ip, :name, :uid, :serial_number, :software_version, :hardware_version,
      :zone_type, :model_number, :mac_address, :group, :icon, :services

    attr_accessor :group_master

    def self.detect(ip)
      data = retrieve_information(ip)
      model_number = data[:model_number]

      # TODO: Clean up
      if Accessory.models.keys.include?(model_number.to_sym)
        Accessory.new(ip, data)
      elsif Speaker.models.keys.include?(model_number.to_sym)
        Speaker.new(ip, data)
      else
        raise ArgumentError.new("#{data[:model_number]} not supported")
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
      @services = data[:services]
    end

    def data
      {
        name: @name,
        uid: @uid,
        serial_number: @serial_number,
        software_version: @software_version,
        hardware_version: @hardware_version,
        zone_type: @zone_type,
        model_number: @model_number,
        services: @services
      }
    end

    # Get the device's model
    # @return [String] a string representation of the device's model
    def model
      self.class.models[@model_number.to_sym]
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
        model_number: doc.xpath('/xmlns:root/xmlns:device/xmlns:modelNumber').inner_text,
        services: doc.xpath('/xmlns:root/xmlns:device/xmlns:serviceList/xmlns:service/xmlns:serviceId').
          collect(&:inner_text)
      }
    end
  end
end
