require 'spec_helper'
require 'net/http'
require 'json'
require 'pry'

RSpec.describe "Metric single user changes [/metrics/{email}]", :type => :request do
  let(:email) { "tester@example.com" }
  let(:uri) { URI.parse("http://emily-cio-homework.getsandbox.com/metrics/#{email}")}
  let(:response) { Net::HTTP.get_response(uri) }

  before(:each) do
    uri = URI.parse('http://emily-cio-homework.getsandbox.com/reset')
    Net::HTTP.get_response(uri)
  end

  describe "Retrieve a Metric [GET]" do
    it "successfully returns a json object" do
      expect(response.content_type).to eq('application/json')
      expect(response.code).to eq '200'
    end

    it "lists tracked metrics for a specific user" do
      body = JSON.parse(response.body)
      expect(body["metrics"]).to eq(["sent", "delivered"])
    end
  end

  # describe "Update a Metric [PUT]" do
  #   it "adds a new metric to a user's tracked metrics" do
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     request = Net::HTTP::Put.new(uri.path, {'Content-Type' => 'application/json'})
  #     data = {'email' => 'tester@example.com', 'metrics' => ['opened', 'clicked']}
  #     request.body = data.to_json
  #     response = http.request(request)
  #     expect(response.code).to eq '201'
  #     expect(JSON.parse(response.body)).to include("email" => 'tester@example.com', "metrics" => ['sent', 'delivered', 'opened', 'clicked'])
  #   end
  # end

  describe "Remove a Metric [DELETE]" do
    it "deletes tracked metrics for a specific user" do
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Delete.new(uri.path)
      response = http.request(request)
      expect(response.code).to eq '200'
    end
  end
end
