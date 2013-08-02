# coding: utf-8
FactoryGirl.define do
  factory :klarna_shipping_address, parent: :shipping_address, class: Spree::KlarnaAddress do
    trait :swedish do
      given_name 'Testperson-se'
      family_name 'Approved'
      street_address 'Stårgatan 1'
      postal_code '12345'
      city 'Ankeborg'
      # country 'se'
      phone '0765260000'
    end

    trait :finnish do
      given_name 'Testperson-fi'
      family_name 'Approved'
      street_address 'Äteritsiputeritsipuolilautatsijänkä 20'
      postal_code '28100'
      city 'Savukoski'
      # country 'fi'
      phone '0765260000'
    end
  end
end
