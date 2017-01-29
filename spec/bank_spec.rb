require 'spec_helper'

describe Bankscrap::Bank do
  before do
    # Stub login and fetch_accounts methods
    allow_any_instance_of(Bankscrap::Bank).to receive(:login)
    allow_any_instance_of(Bankscrap::Bank).to receive(:fetch_accounts)
  end

  describe '#initialize' do
    subject { Bankscrap::Bank.new(user: '1234', password: '1234') }

    it 'should assign the credentials as instance variables' do
      expect(subject.instance_variable_get(:@user)).to eq('1234')
      expect(subject.instance_variable_get(:@password)).to eq('1234')
    end

    context 'with missing credentials' do
      subject { Bankscrap::Bank.new(user: '1234') }
      it 'should raise an error' do
        expect { subject }.to raise_error(Bankscrap::Bank::MissingCredential)
      end
    end

    context 'with credentials stored in env vars' do
      module Bankscrap::TestBank
        class Bank < Bankscrap::Bank; end
      end
      subject { Bankscrap::TestBank::Bank.new }

      before do
        ENV['BANKSCRAP_TEST_BANK_USER'] = '1234'
        ENV['BANKSCRAP_TEST_BANK_PASSWORD'] = '1234'
      end

      it 'should use the credentials from env vars' do
        expect(subject.instance_variable_get(:@user)).to eq('1234')
        expect(subject.instance_variable_get(:@password)).to eq('1234')
      end
    end

    context 'without a proxy' do
      before { Bankscrap.proxy = nil }

      it 'does not use any proxy' do
        expect_any_instance_of(Mechanize).to_not receive(:set_proxy)
        subject
      end
    end

    context 'with a proxy' do
      before { Bankscrap.proxy = { host: 'localhost', port: 8888 } }

      it 'uses the proxy' do
        expect_any_instance_of(Mechanize).to receive(:set_proxy).with('localhost', 8888)
        subject
      end
    end

    context 'with debug enabled' do
      before { Bankscrap.debug = true }

      it 'logs http calls to STDOUT' do
        expect(subject.instance_variable_get(:@http).log).to_not be_nil
      end
    end

    context 'with debug disabled' do
      before { Bankscrap.debug = false }

      it 'logs http calls to STDOUT' do
        expect(subject.instance_variable_get(:@http).log).to be_nil
      end
    end
  end
end
