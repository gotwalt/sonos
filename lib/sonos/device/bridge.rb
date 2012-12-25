require 'savon'
require 'sonos/endpoint'

# Used for Zone Bridge
module Sonos::Device
  class Bridge < Base

    MODEL_NUMBERS = ['ZB100'].freeze

    attr_reader :icon

    def self.model_numbers
      MODEL_NUMBERS
    end
  end
end
