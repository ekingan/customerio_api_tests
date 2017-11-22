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

    it "returns a list tracked metrics for all users, with id, email, and metrics as attributes" do
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
      data_without_email = {'metrics' => ['spammed']}
      request.body = data_without_email.to_json
      response = http.request(request)
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to eq ({"status"=>"error", "details"=>"Missing email"})
    end

    it "creates a new set of tracked metrics for a user" do
      data = {'email' => 'earlybird@gmail.com', 'metrics' => ['sent', 'delivered', 'opened', 'clicked']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '201'
      expect(JSON.parse(response.body)).to include("email" => "earlybird@gmail.com", "metrics" => ['sent', 'delivered', 'opened', 'clicked'])
    end

    it "does not allow invalid metrics to be tracked" do
      data = {'email' => 'madonna@gmail.com', 'metrics' => ['vogue']}
      request.body = data.to_json
      response = http.request(request)
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to include("details" => "Invalid metric: vogue. Must be 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'suppressed', or 'spammed'",
       "status" => "error")
    end

    # it "does not allow duplicate metrics to be tracked" do
    #   data = {'email' => 'bonjovi@gmail.com', 'metrics' => ['sent', 'opened', 'opened', 'sent']}
    #   request.body = data.to_json
    #   response = http.request(request)
    #   expect(response.code).to eq '201'
    #   expect(JSON.parse(response.body)).to include(['sent', 'opened'])
    # end

    it "does not allow duplicate users (by email address)" do
      duplicate_user = {'email' => "tester@example.com", 'metrics' => ['sent']}
      request.body = duplicate_user.to_json
      response = http.request(request)
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to eq({"status"=>"error", "details"=>"Email tester@example.com already created."})
    end
  end
end
