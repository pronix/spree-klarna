require 'spec_helper'

describe Spree::Klarna::CheckoutHandler do

  let(:checkout_handler) { Spree::Klarna::CheckoutHandler.new }
  let(:post_data) do
    {}
  end

  before do
    Spree::Klarna::Config.preferred_shared_secret = "abc"
  end

  context "#post" do  ## uses mocking
    it "sends an HTTP post request to Klarna server" do
      expected_url = "https://checkout.testdrive.klarna.com/checkout/orders"
      Excon.should_receive(:post).with(expected_url, anything())
      checkout_handler.post(data: post_data)
    end

    it "sends JSON payload of given data hash" do
      expected_payload = post_data.to_json
      Excon.should_receive(:post)
      checkout_handler.post(data: post_data)
      checkout_handler.payload.should eq(expected_payload)
    end

    it "sets a custom header" do
      Excon.should_receive(:post)
      checkout_handler.post(data: post_data)
      expected_headers = checkout_handler.klarna_headers
      checkout_handler.headers.should eq(expected_headers)
    end
  end

  context "#put" do ## uses mocking
    it "sends an HTTP post request to Klarna order-update url" do
      expected_url = "https://checkout.testdrive.klarna.com/checkout/orders/23"
      Excon.should_receive(:post).with(expected_url, anything())
      checkout_handler.put(data: post_data, id: 23)
    end

    it "sends JSON payload of the data hash" do
      expected_payload = post_data.to_json
      Excon.should_receive(:post)
      checkout_handler.put(data: post_data, id: 23)
      checkout_handler.payload.should eq(expected_payload)
    end

    it "sets a custom header" do
      Excon.should_receive(:post)
      checkout_handler.post(data: post_data, id: 23)
      expected_headers = checkout_handler.klarna_headers
      checkout_handler.headers.should eq(expected_headers)
    end
  end

  context "#get" do ## uses mocking
    it "sends an HTTP Get request to Klarna order fetch url" do
      expected_url = "https://checkout.testdrive.klarna.com/checkout/orders/23"
      Excon.should_receive(:get).with(expected_url, anything())
      checkout_handler.get(id: 23)
    end

    it "sets a custom header" do
      Excon.should_receive(:get)
      checkout_handler.get(id: 23)
      expected_headers = checkout_handler.klarna_headers
      checkout_handler.headers.should eq(expected_headers)
    end

  end

  context "#klarna_headers" do
    before { checkout_handler.instance_variable_set(:@payload, "sample") }

    it "has Authentication as Klarna *" do
      expect(checkout_handler.klarna_headers["Authentication"]).to match(/Klarna .+/)
    end

    it "has Accept header as application/vnd.klarna.checkout.aggregated-order-v2+json" do
      checkout_handler.klarna_headers["Accept"].should eq("application/vnd.klarna.checkout.aggregated-order-v2+json")
    end

    it "has Content-Type as application/vnd.klarna.checkout.aggregated-order-v2+json" do
      checkout_handler.klarna_headers["Content-Type"].should eq("application/vnd.klarna.checkout.aggregated-order-v2+json")
    end
  end

  context "#klarna_auth_digest" do
    it "is 9slzcBLSXEHfNfbV0D2NhJEnlTJv/V1CnOc5d1JsZ8Y=\n for payload: hello" do
      checkout_handler.instance_variable_set(:@payload,'hello')
      checkout_handler.klarna_auth_digest.should eq("9slzcBLSXEHfNfbV0D2NhJEnlTJv/V1CnOc5d1JsZ8Y=\n")
    end

    it "is IeJursf6cMWO2WljyqQxrL6x4E28PNOBQvTtL5JoPo4=\n when payload is hi" do
      checkout_handler.instance_variable_set(:@payload,'hi')
      checkout_handler.klarna_auth_digest.should eq("IeJursf6cMWO2WljyqQxrL6x4E28PNOBQvTtL5JoPo4=\n")
    end
  end
end
