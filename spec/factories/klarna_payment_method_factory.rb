FactoryGirl.define do
  factory :klarna_payment_method, class: Spree::PaymentMethod::KlarnaInvoice do
      name 'klarna'
      environment 'test'
      active true
  end
end
