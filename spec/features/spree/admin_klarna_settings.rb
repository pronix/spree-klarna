require 'spec_helper'

feature 'Settings for Klarna' do
  given!(:admin) { create(:admin_user) }

  scenario 'update' do
    visit '/admin'
    fill_in 'spree_user_password', with: 'secret'
    fill_in 'spree_user_email', with: @admin.email
    click_button 'Login'

    click_link 'Configuration'
    click_link 'Klarna Settings'

    id = '123456'
    secret = 'asd123asd'

    fill_in 'preferences_id', with: id
    fill_in 'preferences_shared_secret', with: secret

    click_button 'Update'

    expect(page).to have_content('Update successfuly')

    klarna = Spree::KlarnaSetting.new
    klarna[:id].should == id
    klarna[:shared_secret].should == secret
  end
end
