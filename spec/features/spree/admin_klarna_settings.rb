require 'spec_helper'

feature 'settings for klarna' do

  background :each do
    @admin = create(:admin_user)
  end

  scenario 'set klarna settings' do
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

    klarna = Spree::KlarnaSetting.new
    klarna[:id].should == id
    klarna[:shared_secret].should == secret
  end

end
