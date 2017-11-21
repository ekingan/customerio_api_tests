require 'spec_helper'
require 'net/http'
require 'json'

RSpec.describe "Metric Collection [/metrics]", :type => :request do
  let(:uri) { URI.parse('http://emily-cio-homework.getsandbox.com/metrics')}
  let(:response) { Net::HTTP.get_response(uri) }

  describe "The Metric Collection contains endpoints for managing user metrics" do
    it "successfully returns a json object" do
      expect(response.content_type).to eq('application/json')
      expect(response.code).to eq '200'
    end

    it "has attributes id, email, and metrics" do
      body = JSON.parse(response.body)
      body['metrics'].each do |metric|
        expect(metric).to include('id')
        expect(metric).to include('email')
        expect(metric).to include('metrics')
      end
    end
  end
end
