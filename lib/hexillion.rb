require 'date'
require 'net/http'
require 'nokogiri'
require 'openssl'
require 'uri'

module Hexillion
  class Client
    AUTH_ENDPOINT = "https://hexillion.com/rf/xml/1.0/auth/".freeze
    DATA_ENDPOINT = "http://hexillion.com/rf/xml/1.0/whois/".freeze

    def initialize(options)
      @session_key = fetch_session_key(options)
    rescue
      raise "Authentication failed"
    end

    # Query the API for a given domain
    #
    # @example
    #   client.whois('flippa.com', {optional_param: value, ...})
    #
    #

    def whois(domain, extra_params = {})
      params = {sessionkey: @session_key, query: domain}.merge(extra_params)

      uri = URI(DATA_ENDPOINT)
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      parse_xml(response.body)
    end

    private

    def fetch_session_key(options = {})
      uri = URI(AUTH_ENDPOINT)

      http = Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(username: options[:username], password: options[:password])
      response = http.request(request)

      doc = Nokogiri::XML(response.body)
      doc.at_css('SessionKey').content
    end

    def parse_xml(xml)
      doc = Nokogiri::XML(xml)

      records = doc.xpath(
        <<~XPATH
          .//QueryResult[
            ErrorCode='Success' and
            FoundMatch='Yes'
          ]/WhoisRecord
        XPATH
      )

      strings = {
        registrant_name: "Registrant Name",
        registrant_person: "Registrant Person",
        registrant_handle: "Registrant Handle",
        registrant_address: "Registrant Address",
        registrant_city: "Registrant City",
        registrant_state_province: "Registrant StateProvince",
        registrant_postal_code: "Registrant PostalCode",
        registrant_country: "Registrant Country",
        registrant_country_code: "Registrant CountryCode",
        registrant_email: "Registrant Email",
        registrar_name: "Registrar Name",
        registrar_whois_server: "Registrar WhoisServer",
        registrar_homepage: "Registrar HomePage",
        admin_contact_name: "AdminContact Name",
        admin_contact_person: "AdminContact Person",
        admin_contact_handle: "AdminContact Handle",
        admin_contact_address: "AdminContact Address",
        admin_contact_state_province: "AdminContact StateProvince",
        admin_contact_postal_code: "AdminContact PostalCode",
        admin_contact_country_code: "AdminContact CountryCode",
        admin_contact_country: "AdminContact Country",
        admin_contact_email: "AdminContact Email",
        admin_contact_phone: "AdminContact Phone",
        admin_contact_fax: "AdminContact Fax",
        tech_contact_name: "TechContact Name",
        tech_contact_person: "TechContact Person",
        tech_contact_handle: "TechContact Handle",
        tech_contact_address: "TechContact Address",
        tech_contact_state_province: "TechContact StateProvince",
        tech_contact_postal_code: "TechContact PostalCode",
        tech_contact_country_code: "TechContact CountryCode",
        tech_contact_country: "TechContact Country",
        tech_contact_email: "TechContact Email",
        tech_contact_phone: "TechContact Phone",
        tech_contact_fax: "TechContact Fax",
        zone_contact_name: "ZoneContact Name",
        zone_contact_person: "ZoneContact Person",
        zone_contact_handle: "ZoneContact Handle",
        zone_contact_address: "ZoneContact Address",
        zone_contact_state_province: "ZoneContact StateProvince",
        zone_contact_postal_code: "ZoneContact PostalCode",
        zone_contact_country_code: "ZoneContact CountryCode",
        zone_contact_country: "ZoneContact Country",
        zone_contact_email: "ZoneContact Email",
        zone_contact_phone: "ZoneContact Phone",
        zone_contact_fax: "ZoneContact Fax",
        header_text: "HeaderText",
        stripped_text: "StrippedText",
        raw_text: "RawText",
      }

      dates = {
        created_date: './CreatedDate',
        expires_date: './ExpiresDate',
        updated_date: './UpdatedDate',
      }

      result = { xml_response: xml }

      records.each do |record|
        result[:nameservers] = record.css('Domain NameServer').map { |x| x.content unless x.content == '' }

        strings.each do | attr, selector |
          nodes = record.css(selector)
          next if nodes.empty?
          if nodes.size == 1 || selector.include?('Email')
            result[attr] = nodes[0].content unless nodes[0].content == ''
          else
            result[attr] = nodes.to_a.reject { |s| s.blank? }.join("\n")
          end
        end

        dates.each do | attr, selector |
          next unless node = record.at_xpath(selector)
          result[attr] = DateTime.parse(node.content) unless node.content == ''
        end
      end

      result
    end
  end
end
