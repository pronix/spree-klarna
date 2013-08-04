require 'spec_helper'

feature 'Settings for Klarna' do
  given!(:admin) { create(:admin_user) }

  scenario 'update' do
    visit '/admin'
    fill_in 'spree_user_password', with: 'secret'
    fill_in 'spree_user_email', with: admin.email
    click_button 'Login'

    click_link 'Configuration'
    click_link 'Payment Methods'
    click_link 'New Payment Method'

    select 'Spree::PaymentMethod::KlarnaInvoice', :from => 'gtwy-type'
    fill_in 'payment_method_name', with: 'klarna'
    click_button 'Create'


    id = '123456'
    secret = 'asd123asd'

    fill_in 'payment_method_klarna_invoice_preferred_id', with: id
    fill_in 'payment_method_klarna_invoice_preferred_shared_secret', with: secret

    click_button 'Update'

    expect(page).to have_content('Payment Method has been successfully updated!')

    klarna = Spree::PaymentMethod::KlarnaInvoice.first
    klarna.preferred_id.should == id
    klarna.preferred_shared_secret.should == secret
  end
end
