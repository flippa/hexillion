require "hexillion/version"

module Hexillion
  class Client
    def initialize(options)
      base = "https://%s:%s@webservices.quova.com/ipinfo"
      @resource = RestClient::Resource.new(base % [options[:id], options[:password]])
    end
  end
end
