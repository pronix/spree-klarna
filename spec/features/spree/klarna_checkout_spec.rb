require 'spec_helper'

feature 'Klarna Checkout' do
  background do
    @user = create(:klarna_user, :swedish)

    zone = create(:zone, name: 'CountryZone')
    @ship_cat = create(:shipping_category, name: 'all')

    @product = create(:base_product, name: 'Moose Roadsign')
    @product.shipping_category = @ship_cat
    @product.save!

    @country = create(:country,
                      iso_name: 'SWEDEN',
                      name:     'Sweden',
                      iso:      'SE',
                      iso3:     'SE',
                      numcode:  46)

    @country.states_required = false
    @country.save!

    @state = @country.states.create(name: 'Stockholm')

    zone.members.create(zoneable: @country, zoneable_type: 'Country')

    ship_meth = create(:shipping_method,
        calculator_type: 'Spree::Calculator::Shipping::FlatRate',
        display_on: 'both')

    ship_meth.zones << zone
    ship_meth.shipping_categories << @ship_cat
    ship_meth.calculator.preferred_amount = 90
    ship_meth.save!

    @pay_method = create(:klarna_payment_method)
  end

  pending 'complete checkout' do
    name = @product.name
    visit spree.root_path
    expect(page).to have_content(name)
    click_link name
    click_button 'add-to-cart-button'
    click_button 'checkout-link'
    fill_in 'order_email', with: @user.email
    click_button 'Continue'

    # fill addresses
    check 'order_use_billing'
    addr = 'order_bill_address_attributes_'
    fill_in "#{addr}firstname", with: 'Joe'
    fill_in "#{addr}lastname",  with: 'User'
    fill_in "#{addr}address1",  with: '7735 Old Georgetown Road'
    fill_in "#{addr}address2",  with: 'Suite 510'
    fill_in "#{addr}city",      with: 'Bethesda'
    fill_in "#{addr}zipcode",   with: '20814'
    fill_in "#{addr}phone",     with: '301-444-5002'
    within 'fieldset#billing' do
      select @country.name, from: 'Country'
    end

    click_button 'Save and Continue'

    # shipping
    click_button 'Save and Continue'

    # payment page
    pending 'not add yet by deface override'
    fill_in 'social_security_number', with: '410321-9202'
    click_button 'Save and Continue'

    # confirm
    # FIXME undefined method `authorize' for #<Spree::PaymentMethod::KlarnaInvoice:0x0000000d4c8ee0>
    click_button 'Place Order'
    #
    # as result require receive invoice and check that invoice created in klarna
  end
end
