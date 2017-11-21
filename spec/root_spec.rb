require 'spec_helper'
require 'net/http'

RSpec.describe "Root route", :type => :request do
  let(:uri) { URI.parse('http://emily-cio-homework.getsandbox.com/')}
  describe "Get root route" do
    it "should successfully return a json object" do
      response = Net::HTTP.get_response(uri)
      expect(response.content_type).to eq('application/json')
      expect(response.code).to eq('200')
    end
  end
end
