require File.expand_path("../../../spec_helper", __FILE__)

module Heroku::Command
  describe Certs do
    let(:endpoint) {
      { 'cname'          => 'tokyo-1050', 
        'ssl_cert' => {
          'ca_signed?'   => false, 
          'cert_domains' => [ 'example.org' ], 
          'starts_at'    => Time.now.to_s, 
          'expires_at'   => (Time.now + 30 * 365 * 24 * 3600).to_s, 
          'issuer'       => 'subject: /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org', 
          'subject'      => 'subject: /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org', 
        }
      }
    }
    let(:endpoint2) {
      { 'cname'          => 'akita-7777', 
        'ssl_cert' => {
          'ca_signed?'   => true,
          'cert_domains' => [ 'heroku.com' ],
          'starts_at'    => Time.now.to_s,
          'expires_at'   => (Time.now + 30 * 365 * 24 * 3600).to_s,
          'issuer'       => 'subject: /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
          'subject'      => 'subject: /C=US/ST=California/L=San Francisco/O=Heroku by Salesforce/CN=secure.example.org',
        }
      }
    }

    before do
      @certs = prepare_command(Certs)
    end

    describe "certs:index" do
      it "lists endpoints" do
        @certs.heroku.should_receive(:ssl_endpoint_list).with('myapp').and_return([ endpoint, endpoint2 ])
        @certs.index
      end

      it "correctly handles an empty list" do
        @certs.heroku.should_receive(:ssl_endpoint_list).with('myapp').and_return([])
        @certs.index
      end
    end

    describe "certs:add" do
      it "adds an endpoint" do
        @certs.should_receive(:args).at_least(:once).and_return(['pem_file', 'key_file'])
        File.should_receive(:read).with('pem_file').and_return('pem content')
        File.should_receive(:read).with('key_file').and_return('key content')

        @certs.heroku.should_receive(:ssl_endpoint_add).with('myapp', 'pem content', 'key content').and_return(endpoint)
        @certs.add
      end

      it "shows usage if two arguments are not provided" do
        @certs.stub!(:args).and_return([])
        lambda { @certs.add }.should raise_error(CommandFailed, /Usage:/)
      end
    end

    context "existing cname" do
      before do
        @certs.heroku.stub!(:ssl_endpoint_list).with('myapp').and_return([ endpoint2 ])
      end

      describe "certs:info" do
        it "shows an endpoint" do
          @certs.heroku.stub!(:ssl_endpoint_info).with('myapp', 'akita-7777').and_return(endpoint2)
          @certs.info
        end
      end

      describe "certs:remove" do
        it "removes an endpoint by querying server for a cname" do
          @certs.heroku.should_receive(:ssl_endpoint_remove).with('myapp', 'akita-7777').and_return({ 'cname' => 'akita-7777' })
          @certs.remove
        end

        it "removes an endpoint specified as an option" do
          @certs.stub!(:options).and_return({ :endpoint => 'kyoto-1234' })
          @certs.heroku.should_receive(:ssl_endpoint_remove).with('myapp', 'kyoto-1234').and_return({ 'cname' => 'akita-7777' })
          @certs.remove
        end
      end

      describe "certs:update" do
        it "updates an endpoint by querying server for a cname" do
          @certs.should_receive(:args).at_least(:once).and_return(['pem_file', 'key_file'])
          File.should_receive(:read).with('pem_file').and_return('pem content')
          File.should_receive(:read).with('key_file').and_return('key content')

          @certs.heroku.should_receive(:ssl_endpoint_update).with('myapp', 'akita-7777', 'pem content', 'key content').and_return(endpoint2)
          @certs.update
        end

        it "removes an endpoint specified as an option" do
          @certs.stub!(:options).and_return({ :endpoint => 'kyoto-1234' })
          @certs.should_receive(:args).at_least(:once).and_return(['pem_file', 'key_file'])
          File.should_receive(:read).with('pem_file').and_return('pem content')
          File.should_receive(:read).with('key_file').and_return('key content')
          @certs.heroku.should_receive(:ssl_endpoint_update).with('myapp', 'kyoto-1234', 'pem content', 'key content').and_return(endpoint2)
          @certs.update
        end

        it "shows usage if two arguments are not provided" do
          @certs.stub!(:args).and_return([])
          lambda { @certs.update }.should raise_error(CommandFailed, /Usage:/)
        end
      end

      describe "certs:rollback" do
        it "rolls back an endpoint by querying server for a cname" do
          @certs.heroku.should_receive(:ssl_endpoint_rollback).with('myapp', 'akita-7777').and_return(endpoint2)
          @certs.rollback
        end

        it "rolls back an endpoint specified as an option" do
          @certs.stub!(:options).and_return({ :endpoint => 'kyoto-1234' })
          @certs.heroku.should_receive(:ssl_endpoint_rollback).with('myapp', 'kyoto-1234').and_return(endpoint2)
          @certs.rollback
        end
      end
    end
  end
end
