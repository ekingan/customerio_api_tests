require 'spec_helper'
require 'net/http'

RSpec.describe "Metric API Root route", :type => :request do

  let(:uri) { URI.parse('http://emily-cio-homework.getsandbox.com/')}
  let(:response) { Net::HTTP.get_response(uri) }

  describe "Retrieve the entry point [GET]" do
    it "should successfully return a json object" do
      expect(response.content_type).to eq('application/json')
      expect(response.code).to eq('200')
    end
  end
end
