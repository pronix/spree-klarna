require 'spec_helper'

describe Spree::PaymentMethod::KlarnaInvoice do
  context '.source_required?' do
    specify do
      subject.source_required?.should be_true
    end
  end

  context '.payment_source_class' do
    specify do
      subject.payment_source_class.should == Spree::KlarnaPayment
    end
  end

  context '.payment_profiles_supported?' do
    specify do
      subject.payment_profiles_supported?.should be_true
    end
  end
end
