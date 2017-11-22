require 'spec_helper'

RSpec.describe "Metric single user changes [/metrics/{email}]", :type => :request do

  let(:email) { "tester@example.com" }
  let(:uri) { URI.parse("http://emily-cio-homework.getsandbox.com/metrics/#{email}")}
  let(:response) { Net::HTTP.get_response(uri) }
  let(:http) { Net::HTTP.new(uri.host, uri.port) }

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

  describe "Update a Metric [PUT]" do
    it "adds a new metric to a user's tracked metrics" do
      data = {'metric' => 'opened'}
      response = http.send_request('PUT', uri.path, JSON.dump(data), {'Content-Type' => 'application/json'})
      expect(response.code).to eq '200'
      expect(JSON.parse(response.body)["metrics"]).to eq(["sent", "delivered", "opened"])
    end

    it "does not allow invalid metrics to be tracked" do
      data = {'metric' => 'sleepy'}
      response = http.send_request('PUT', uri.path, JSON.dump(data), {'Content-Type' => 'application/json'})
      expect(JSON.parse(response.body)["metrics"]).not_to eq(["sent", "delivered", "sleepy"])
      expect(response.code).to eq '400'
    end
  end

  describe "Remove a Metric [DELETE]" do
    it "deletes tracked metrics for a specific user" do
      request = Net::HTTP::Delete.new(uri.path)
      response = http.request(request)
      expect(response.code).to eq '200'
      expect(response.body).to eq ""
    end
  end
end
