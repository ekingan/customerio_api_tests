require 'spec_helper'
require 'net/http'
require 'json'

RSpec.describe "Metric Collection [/metrics]", :type => :request do

  let(:uri) { URI.parse('http://emily-cio-homework.getsandbox.com/metrics')}
  let(:response) { Net::HTTP.get_response(uri) }
  let(:http) { Net::HTTP.new(uri.host, uri.port) }
  let(:request) { Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})}

  before(:each) do
    uri = URI.parse('http://emily-cio-homework.getsandbox.com/reset')
    Net::HTTP.get_response(uri)
  end

  describe "List all Metrics [GET]" do
    it "successfully returns a json object" do
      expect(response.content_type).to eq('application/json')
      expect(response.code).to eq '200'
    end

    it "has id, email, and metrics as attributes" do
      body = JSON.parse(response.body)
      body['metrics'].each do |metric|
        expect(metric).to include('id')
        expect(metric).to include('email')
        expect(metric).to include('metrics')
      end
    end
  end

  describe "Create a Metric [POST]" do
    it "accepts email and metrics as parameters" do
      data = {'email' => 'ekingan1@gmail.com', 'metrics' => ['sent', 'delivered']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '201'
      expect(JSON.parse(response.body)).to include("email" => "ekingan1@gmail.com", "metrics" => ["sent", "delivered"])
    end

    it "requires that an email address is included in parameters" do
      data = {'metrics' => ['spammed']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to eq ({"status"=>"error", "details"=>"Missing email"})
    end

    it "accepts an array of metrics" do
      data = {'email' => 'earlybird@gmail.com', 'metrics' => ['sent', 'delivered', 'opened', 'clicked']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '201'
      expect(JSON.parse(response.body)).to include("email" => "earlybird@gmail.com", "metrics" => ['sent', 'delivered', 'opened', 'clicked'])
    end

    it "only accepts the folling metrics: `sent`, `delivered`, `opened`, `clicked`, `bounced`, `suppressed`, or `spammed`" do
      data = {'email' => 'madonna@gmail.com', 'metrics' => ['true', 'blue']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to include("details" => "Invalid metric: true. Must be 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'suppressed', or 'spammed'",
       "status" => "error")
    end
  end


end
