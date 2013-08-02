FactoryGirl.define do
  factory :klarna_payment, class: Spree::KlarnaPayment do
    association(:source, factory: :payment)
    personal_identity_number { "#{(100000..500000).sample}-9202" }
    invoice_number nil

    trait :swedish do
      personal_identity_number '410321-9202'
    end

    trait :finnish do
      personal_identity_number '190122-829F'
    end
  end
end
