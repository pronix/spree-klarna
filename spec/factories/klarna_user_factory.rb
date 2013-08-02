FactoryGirl.define do
  factory :klarna_user, aliases: [:test_person], parent: :user do
    trait :swedish do
      email 'checkout-se@testdrive.klarna.com'
    end

    trait :finnish do
      email 'checkout-fi@testdrive.klarna.com'
    end
  end
end
