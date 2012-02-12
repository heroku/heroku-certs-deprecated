require File.expand_path("../../spec_helper", __FILE__)

module Heroku
  describe RunWithStatus do
    before do
      @dummy = Class.new do
        include Helpers
        include RunWithStatus
      end.new

      @output = ""
      @dummy.stub(:display) do |str, *args|
        @output += str
        @output += "\n" if args.count < 1 || args.first
      end
    end

    it "runs successfully" do
      @dummy.run_with_status('updating') {}
      @output.should include "--> updating... done"
    end

    it "includes a failed message on RestClient::RequestFailed" do
      run_with_http_error RestClient::RequestFailed, "only one SSL endpoint allowed per app"
      @output.should include "--> updating... failed"
      @output.should include "only one SSL endpoint allowed"
    end

    it "includes a failed message on RestClient::RequestTimeout" do
      run_with_http_error RestClient::RequestTimeout, 'wut'
      @output.should include "--> updating... failed"
      @output.should include "request timed out"
    end

    it "includes a failed message on RestClient::ResourceNotFound" do
      run_with_http_error RestClient::ResourceNotFound
      @output.should include "--> updating... failed"
      @output.should include "not found"
    end

    private

    def run_with_http_error(klass, error = nil)
      lambda do
        @dummy.run_with_status('updating') do
          e = klass.new
          e.stub(:http_body).and_return("<errors><error>#{error}</error></errors>") if error
          raise e
        end
      end.should raise_error SystemExit
    end
  end
end
