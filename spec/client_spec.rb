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
      RestClient
        .should_receive(:post)
        .with("https://hexillion.com/rf/xml/1.0/auth/", {:username => "username", :password => "password"})
        .and_return(AUTH_RESPONSE)
      hex = Hexillion::Client.new(:username => "username", :password => "password")
      hex.instance_variable_get('@session_key').should == 'nOIANdfjL4524ynjlssasjfDFaqe4'
    end
  end
  
  describe "#whois" do
    before(:each) do
      @response = double()
      RestClient.stub(:post) { AUTH_RESPONSE }
      RestClient.stub(:get) { @response }
      @response.stub(:body) { "" }
      @hex = Hexillion::Client.new(:username => "username", :password => "password")
    end
    
    it "queries the API for the provided domain" do
      RestClient.should_receive(:get)
      @hex.whois("example.com")
    end
    
    it "concats multiline address fields" do
      @response.stub(:body) do
        <<-XML
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Registrant>
            <Address>48 Cambridge Street</Address>
            <Address>Level 3</Address>
          </Registrant>
        </WhoisRecord></QueryResult>
        XML
      end
      
      @hex.whois("example.com")[:registrant_address].should == "48 Cambridge Street\nLevel 3"
    end
    
    it "makes an array of nameservers" do
      @response.stub(:body) do
        <<-XML        
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <Domain>
            <NameServer>ns1.registrar.com</NameServer>
            <NameServer>ns2.registrar.com</NameServer>
            <NameServer>ns3.registrar.com</NameServer>
          </Domain>
        </WhoisRecord></QueryResult>
        XML
      end
      
      @hex.whois("example.com")[:nameservers].should == ['ns1.registrar.com', 'ns2.registrar.com', 'ns3.registrar.com']
    end

    it "parses date fields" do
      @response.stub(:body) do
        <<-XML        
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
          <CreatedDate>1999-10-04T00:00:00Z</CreatedDate>
          <UpdatedDate>2010-11-25T00:00:00Z</UpdatedDate>
          <ExpiresDate>2019-10-04T00:00:00Z</ExpiresDate>
        </WhoisRecord></QueryResult>
        XML
      end  
      
      @hex.whois("example.com")[:created_date].should == DateTime::civil(1999,10,4)
    end
    
    it "returns the entire xml response as :xml_response" do
      xml = <<-XML        
        <QueryResult><ErrorCode>Success</ErrorCode><FoundMatch>Yes</FoundMatch><WhoisRecord>
              <CreatedDate>1999-10-04T00:00:00Z</CreatedDate>
              <UpdatedDate>2010-11-25T00:00:00Z</UpdatedDate>
              <ExpiresDate>2019-10-04T00:00:00Z</ExpiresDate>
            </WhoisRecord></QueryResult>
            XML
            
      @response.stub(:body) { xml }
      
      @hex.whois("example.com")[:xml_response].should == xml
    end
  end
end