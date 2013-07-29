module Spree
  module Klarna
    class Order
    	attr_reader :id, :properties, :checkout_handler
    	attr_accessor :spree_order

    	def initialize(args={})
    		@id = args[:id]
    		@checkout_handler = Spree::Klarna::CheckoutHandler.new
    	end

    	def create
    		data = setup_properties_for_create
    		@checkout_handler.post(data: data)
    	end

    	def fetch
    		@checkout_handler.get(id: @id)
    	end

    	def update
    		data = setup_properties_for_update
    		@checkout_handler.put(id: @id, data: data)
    	end

    	def setup_properties_for_create
    		properties = {}
    		properties[:purchase_country]  = spree_order_purchase_country
    		properties[:purchase_currency] = spree_order_purchase_currency
    		properties[:locale]            = spree_order_locale
    		properties[:cart]              = cart_properties
    		properties[:merchant]          = merchant_properties
    		properties
    	end

    	def setup_properties_for_update
    		setup_properties_for_create
    	end

    	def cart_properties
    		{ items: @spree_order.line_items.map{ |item| cart_item_data(item) }}
    	end

    	def cart_item_data(item)
        h                 = {}
        h[:reference]     = spree_item_reference      item   ## mandatory
        h[:name]          = spree_item_name           item   ## mandatory
        h[:quantity]      = spree_item_quantity       item   ## mandatory
        h[:unit_price]    = spree_item_unit_price     item   ## mandatory
        h[:tax_rate]      = spree_item_tax_rate       item   ## mandatory
        h[:type]          = spree_item_type           item   ## optional
        #h[:ean]           = spree_item_ean            item   ## optional
        h[:uri]           = spree_item_uri            item   ## optional
        h[:image_uri]     = spree_item_image_uri      item   ## optional
        h[:discount_rate] = spree_item_discount_rates item   ## optional
    		h
    	end


    	def merchant_properties
    		{
    			id:               Spree::Klarna::Config.preferred_id,
    			terms_uri:        Spree::Klarna::Config.preferred_terms_uri,
    			checkout_uri:     Spree::Klarna::Config.preferred_checkout_uri,
    			confirmation_uri: Spree::Klarna::Config.preferred_confirmation_uri,
    			push_uri:         Spree::Klarna::Config.preferred_push_uri
    		}
    	end

      def spree_order_purchase_country
        @spree_order.bill_address.country.iso
      end

      def spree_order_purchase_currency
        Spree::Config.preferred_currency
      end

      def spree_order_locale
        case I18n.locale
          when :sv;   'sv-se'
          when :fi;   'fi-fi'
          else ;      ''
        end
      end

      def spree_item_reference(item)
        item.variant.sku
      end

      def spree_item_name(item)
        item.variant.name
      end

      def spree_item_quantity(item)
        item.quantity
      end

      def spree_item_unit_price(item)
        item.price.to_f * 100
      end

      def spree_item_tax_rate(item)
        tax_category = item.variant.tax_category
        tax_rate = tax_category.tax_rates.by_zone(spree_zone_id).last if tax_category
        tax = tax_rate.amount.to_f * 100  if tax_rate
        tax.to_i
      end

      def spree_zone_id
        Spree::Zone.find_by_name(Spree::Klarna::Config.preferred_eu_zone_name).id
      end

      def spree_item_type(item)
        'physical'
      end

      def spree_item_ean(item)
        ""  # sku matches best for this, but is being used for reference. This is optional, so leave
      end

      def spree_item_uri(item)
        url_common + item.variant.permalink
      end

      def url_common
        "http://#{Spree::Config[:site_url]}/"
      end

      def spree_item_image_uri(item)
        images = item.variant.images
        if images.blank?
          ''
        else
          attachment_url = images.first.attachment.url
          url_common + attachment_url
        end
      end

      def spree_item_discount_rates(item)
        item.adjustments.sum(&:amount)/item.price * 100
      end


    	def empty_properties
        ## O, optional
        ## M, mandatory
        ## R, read only
        ##
        ## # <letter1> <letter2> #
        ## letter1: checkout_incomplete
        ## letter2: checkout_complete/created
        ## eg:
        ## # MR # Mandatory in checkout_incomplete, Read Only when checkout_complete
        ##
        ## checkout_incomplete:mandatory properties:
        ##
        ##   purchase_country
        ##   purchase_currency
        ##   locale
        ##   cart.items[0].reference
        ##   cart.items[0].name
        ##   cart.items[0].quantity
        ##   cart.items[0].unit_price
        ##   cart.items[0].tax_rate
        ##   merchant.id
        ##   merchant.terms_uri
        ##   merchant.checkout_uri
        ##   merchant.confirmation_uri
        ##   merchant.push_uri
        ##
        ## checkout_incomplete: optional properties:
        ##
        ##   merchant_reference
        ##   shipping_address.given_name
        ##   shipping_address.family_name
        ##   shipping_address.care_of
        ##   shipping_address.street_address
        ##   shipping_address.postal_code
        ##   shipping_address.city
        ##   shipping_address.country
        ##   shipping_address.email
        ##   shipping_address.phone
        ##   cart.items[0].type
        ##   cart.items[0].ean
        ##   cart.items[0].uri
        ##   cart.items[0].image_uri
        ##   cart.items[0].discount_rate
        ##   gui.layout
        ##   gui.options
        ##
    		{
    			id: "",                     # RR # Unique identifier of the Klarna Checkout Order
    			merchant_reference: "",     # OO # Container for merchant reference. Currently supported keys are orderid1 and orderid2
    			purchase_country: "",       # MR # Country in which the purchase is done (ISO-3166-alpha2)
    			purchase_currency: "",      # MR # Currency in which the purchase is done (ISO-4217)
    			locale: "",                 # MR # Locale indicative for language & other location-specific details (RFC1766)
    			status: "",                 # RO # Status. `checkout_incomplete` by default, alternatively `checkout_complete`, `created`
    			reference: "",              # RR # End-consumer friendly reference
    			reservation: "",            # RR # Reservation number to be used in the XML-RPC API
    			started_at: "",             # RR # Timestamp of when the Checkout started (ISO-8601)
    			completed_at: "",           # RR # Timestamp of when the Checkout was completed (ISO-8601)
    			created_at: "",             # RR # Timestamp of when the Order was created (ISO-8601)
    			last_modified_at: "",       # RR # Timestamp of when the Checkout was last modified (ISO-8601)
    			expires_at: "",             # RR # Timestamp of when the Checkout will expire (ISO-8601)
    			billing_address: {          # RR # Billing address
    				given_name: "",           # RR # Given name
    				family_name: "",          # RR # Family name
    				care_of: "",              # RR # c/o
    				street_address: "",       # RR # billing_address.street_address
    				postal_code: "",          # RR # Postal code
    				city: "",                 # RR # City
    				country: "",              # RR # Country (ISO-3166 alpha)
    				email: "",                # RR # E-mail address
    				phone: ""                 # RR # Phone number
    			},
    			shipping_address:{          # OR # Shipping address
    				given_name: "",           # OR # Given name
    				family_name: "",          # OR # Family name
    				care_of: "",              # OR # c/o
    				street_address: "",       # OR # Street address (street name, street number, street extension)
    				postal_code: "",          # OR # Postal code
    				city: "",                 # OR # City
    				country: "",              # OR # Country (ISO-3166 alpha)
    				email: "",                # OR # E-mail address
    				phone: ""    				      # OR # Phone number
    			},
    			cart: {
    				total_price_excluding_tax: "",       # RR # Total price (excluding tax) in cents
    				total_tax_amount: "",                # RR # Total tax amount in cents
    				total_price_including_tax: "",       # RR # Total price (including tax) in cents
    				items: [
    					{ type: "",                        # OR # Type. `physical` by default, alternatively `discount`, `shipping_fee`
    						ean: "",                         # OR # The item's International Article Number. Please note this property is currently not returned when fetching the full order resource.
    						reference: "",                   # MR # Reference, usually the article number
    						name: "",                        # MR # Name, usually a short description
    						uri: "",                         # OR # Item product page URI. Please note this property is currently not returned when fetching the full order resource.
    						image_uri: "",                   # OR # Item image URI. Please note this property is currently not returned when fetching the full order resource.
    						quantity: "",                    # MR # Quantity
    						unit_price: "",                  # MR # Unit price in cents, including tax
    						total_price_excluding_tax: "",   # RR # Total price (excluding tax) in cents
    						total_tax_amount: "",            # RR # Total tax amount, in cents
    						total_price_including_tax: "",   # RR # Total price (including tax) in cents
    						discount_rate: "",               # OR # Percentage of discount, multiplied by 100 and provided as an integer. i.e. 9.57% should be sent as 957
    						tax_rate: ""                     # MR # Percentage of tax rate, multiplied by 100 and provided as an integer. i.e. 13.57% should be sent as 1357
    					}
    				]
    			},
  				customer: {
  					type: ""                  # RR # Type. Currently the only supported value is 'person'
  				},
  				gui: {                      # OR #
  					layout: "",               # OR # Layout. `desktop` by default, alternatively `mobile`
  					options: "",              # OR # An array of options to define the checkout behaviour. Supported options `disable_autofocus`.
  					snippet: ""               # RR # HTML snippet
  				},
  				merchant: {
  					id: "",                   # MR # Unique identifier (EID)
  					terms_uri: "",            # MR # URI of your terms and conditions
  					checkout_uri: "",         # MR # URI of your checkout page
  					confirmation_uri: "",     # MR # URI of your confirmation page
  					push_uri: ""              # MR # URI of your push-notification page
  				}
    		}
    	end
    end
  end
end
