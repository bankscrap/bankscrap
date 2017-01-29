require 'spec_helper'

describe Bankscrap::Transaction do
  describe '#initialize' do
    context 'the received amount is a Money object' do
      subject { Bankscrap::Transaction.new(amount: Money.new(1000, 'EUR')) }

      it 'raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'the received amount is not a Money object' do
      subject { Bankscrap::Transaction.new(amount: 100) }

      it 'raise an exception' do
        expect { subject }.to raise_error(Bankscrap::NotMoneyObjectError)
      end
    end
  end
end
