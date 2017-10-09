require 'spec_helper'

AUTH_RESPONSE =  '<?xml version="1.0" encoding="utf-8" ?>
                  <AuthResult>
                    <ErrorCode>Success</ErrorCode>
                    <Message>The service successfully processed your request.</Message>
                    <SessionKey>nOIANdfjL4524ynjlssasjfDFaqe4</SessionKey>
                  </AuthResult>'

describe Hexillion::Client do
  describe '#initialize' do
    it "requests a session key from Hexillion and assigns it as an instance variable" do
      http = double(Net::HTTP, :'use_ssl=' => 1, :'verify_mode=' => 1)
      post = double(Net::HTTP::Post, 'set_form_data' => 1)
      resp = double(body: AUTH_RESPONSE)

      allow(Net::HTTP).to receive(:new) { http }
      allow(Net::HTTP::Post).to receive(:new) { post }

      expect(http).to receive(:request).with(post).and_return(resp)

      hex = Hexillion::Client.new(:username => "username", :password => "password")
      expect(hex.instance_variable_get('@session_key')).to eq('nOIANdfjL4524ynjlssasjfDFaqe4')
    end
  end

  describe "#whois" do
    before(:each) do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .with(an_instance_of(Net::HTTP::Post))
        .and_return(double(body: AUTH_RESPONSE))

      @response_body = ""

      allow(@response).to receive(:body) { @response_body }
      allow(Net::HTTP).to receive(:get_response) { @response }

      @hex = Hexillion::Client.new(:username => "username", :password => "password")
    end

    it "queries the API and passes all the params to the endpoint" do
      domain_name = "example.com"
      extra_params = {:data => "awesome", :more_data => "awesomer"}

      request_uri = URI([
        "http://hexillion.com/rf/xml/1.0/whois/",
        "?sessionkey=nOIANdfjL4524ynjlssasjfDFaqe4",
        "&query=#{domain_name}",
        "&data=#{extra_params[:data]}",
        "&more_data=#{extra_params[:more_data]}",
      ].join)

      expect(Net::HTTP).to receive(:get_response).with(request_uri)
      @hex.whois(domain_name, extra_params)
    end

    it "concats multiline address fields" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Registrant>
            <Address>48 Cambridge Street</Address>
            <Address>Level 3</Address>
          </Registrant>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:registrant_address]).to eq("48 Cambridge Street\nLevel 3")
    end

    it "provides the registrant email address" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Registrant>
            <Address>48 Cambridge Street</Address>
            <Address>Level 3</Address>
            <Email>me@example.com</Email>
          </Registrant>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:registrant_email]).to eq("me@example.com")
    end

    it "returns the first email when multiple specified" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <AdminContact>
            <Email>john@example.com</Email>
            <Email>fred@example.com</Email>
          </AdminContact>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:admin_contact_email]).to eq("john@example.com")
    end

    it "makes an array of nameservers" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Domain>
            <NameServer>ns1.registrar.com</NameServer>
            <NameServer>ns2.registrar.com</NameServer>
            <NameServer>ns3.registrar.com</NameServer>
          </Domain>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:nameservers]).to eq(['ns1.registrar.com', 'ns2.registrar.com', 'ns3.registrar.com'])
    end

    it "parses date fields" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <CreatedDate>1999-10-04T00:00:00Z</CreatedDate>
          <UpdatedDate>2010-11-25T00:00:00Z</UpdatedDate>
          <ExpiresDate>2019-10-04T00:00:00Z</ExpiresDate>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:created_date]).to eq(DateTime::civil(1999,10,4))
    end

    it "returns the entire xml response as :xml_response" do
      xml = <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
              <CreatedDate>1999-10-04T00:00:00Z</CreatedDate>
              <UpdatedDate>2010-11-25T00:00:00Z</UpdatedDate>
              <ExpiresDate>2019-10-04T00:00:00Z</ExpiresDate>
            </WhoisRecord></QueryResult>
      XML

      @response_body = xml

      expect(@hex.whois("example.com")[:xml_response]).to eq(xml)
    end

    it "allows error code 'ParseFailed' in response" do
      @response_body = <<-XML
        <QueryResult><ErrorCode>ParseFailed</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Registrant>
            <Address>48 Cambridge Street</Address>
            <Address>Level 3</Address>
            <Email>me@example.com</Email>
          </Registrant>
        </WhoisRecord></QueryResult>
      XML

      expect(@hex.whois("example.com")[:registrant_email]).to eq("me@example.com")
    end
  end
end
