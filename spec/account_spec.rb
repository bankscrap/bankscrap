require 'spec_helper'

describe Bankscrap::Account do
  describe '#initialize' do
    context 'the received balance is a Money object' do
      subject do
        Bankscrap::Account.new(
          balance: Money.new(1000, 'EUR'),
          available_balance: Money.new(1000, 'EUR'))
      end

      it 'raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'the received balance is not a Money object' do
      subject { Bankscrap::Account.new(balance: 100) }

      it 'raise an exception' do
        expect { subject }.to raise_error(Bankscrap::NotMoneyObjectError)
      end
    end
  end
end
