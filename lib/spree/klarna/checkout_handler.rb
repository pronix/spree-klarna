require 'excon'

module Spree
  module Klarna
    class CheckoutHandler #:nodoc:
      # deal with the klarna rest api here

      @@checkout_url = 'https://checkout.klarna.com/checkout/orders'
      @@sandbox_url  = 'https://checkout.testdrive.klarna.com/checkout/orders'

      attr_reader :data, :payload, :headers

      def get(params)
        @id      = params[:id]
        @payload = ''
        @headers = klarna_headers
        @url     = klarna_url + "/#{@id}"
        Excon.get @url, headers: @headers
      end

      def post(params)
        @data    = params[:data]
        @payload = data.to_json
        @headers = klarna_headers
        @url     = klarna_url
        Excon.post @url, body: @payload, headers: @headers
      end

      def put(params)
        @data    = params[:data]
        @id      = params[:id]
        @payload = data.to_json
        @headers = klarna_headers
        @url     = klarna_url + "/#{@id}"
        Excon.post @url, body: @payload, headers: @headers
      end

      def klarna_headers
        type = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
        {
          'Authentication' => "Klarna #{klarna_auth_digest}",
          'Accept'         => type,
          'Content-Type'   => type
        }
      end

      def klarna_auth_digest
        shared_secret = Spree::PaymentMethod::KlarnaInvoice.first.preferred_shared_secret
        string = @payload.to_s + shared_secret.to_s
        Base64.encode64 OpenSSL::Digest::SHA256.digest(string)
      end

      def klarna_url
        Rails.env.production? ? @@checkout_url : @@sandbox_url
      end
    end
  end
end
