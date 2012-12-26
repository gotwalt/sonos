require 'savon'
require 'sonos/endpoint'

module Sonos::Device

  # Used for Zone Bridge
  class Bridge < Base

    MODEL_NUMBERS = ['ZB100']

    attr_reader :icon

    def self.model_numbers
      MODEL_NUMBERS
    end
  end
end
