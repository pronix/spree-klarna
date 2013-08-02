require 'spec_helper'

feature 'Klarna Checkout', js: true do
  given!(:country)         { create(:country, name: 'Sweden', states_required: false) }
  given!(:shipping_method) { create(:shipping_method) }
  given!(:stock_location)  { create(:stock_location) }
  given!(:product)         { create(:product, name: 'Moose Roadsign') }
  given!(:payment_method)  { create(:klarna_payment_method) }
  given!(:zone)            { create(:zone) }
  given(:testperson)       { create(:test_person, :sweden) }

  background do
    stock_location.stock_items.update_all(count_on_hand: 1)
  end

  pending 'methods' do
    scenario 'should create order with Klarna' do
      add_product_to_cart
      click_button 'Checkout'

      guest_checkout

      fill_in_address

      click_button 'Save and Continue'

      # shipping
      click_button 'Save and Continue'

      # payment page
      fill_in 'social_security_number', with: testperson.personal_identity_number
      click_button 'Save and Continue'

      # confirm
      pending 'undefined method authorize'
      click_button 'Place Order'
    end
  end

  pending 'validations' do
    context 'dosnt allow bad credit card numbers' do
      background do
        order = OrderWalkthrough.up_to(:delivery)
        order.stub :confirmation_required? => true
        order.stub(available_payment_methods: [create(:bogus_payment_method, environment: 'test')])

        user = create(:user)
        order.user = user
        order.update!

        Spree::CheckoutController.any_instance.stub(current_order: order)
        Spree::CheckoutController.any_instance.stub(try_spree_current_user: user)
        Spree::CheckoutController.any_instance.stub(:skip_state_validation? => true)
      end

      scenario 'redirects to payment page' do
        visit spree.checkout_state_path(:delivery)
        click_button 'Save and Continue'
        choose 'Credit Card'
        fill_in 'Card Number', with: '123'
        fill_in 'Card Code',   with: '123'
        click_button 'Save and Continue'
        click_button 'Place Order'
        expect(page).to have_content 'Bogus Gateway: Forced failure'
      end
    end
  end

  def guest_checkout
    fill_in 'order_email', with: testperson.email
    click_button 'Continue'
  end

  def fill_in_address
    addr = 'order_bill_address_attributes_'
    fill_in "#{addr}firstname", with: testperson.firstname
    fill_in "#{addr}lastname",  with: testperson.flastname
    fill_in "#{addr}address1",  with: testperson.address
    fill_in "#{addr}city",      with: testperson.city
    select test_country, from: "#{addr}country_id"
    within 'fieldset#billing' do
      select country.name, from: 'Country'
    end
    fill_in "#{addr}zipcode",   with: testperson.zip
    fill_in "#{addr}phone",     with: testperson.phone
  end

  def add_product_to_cart
    visit spree.root_path
    click_link product.name
    click_button 'add-to-cart-button'
  end
end
