module Bankscrap
  class Account
    include Utils::Inspectable

    attr_accessor :bank, :id, :name, :balance,
                  :available_balance, :description,
                  :transactions, :iban, :bic

    def initialize(params = {})
      raise NotMoneyObjectError.new(:balance) unless params[:balance].is_a?(Money)
      raise NotMoneyObjectError.new(:available_balance) unless params[:available_balance].is_a?(Money)

      params.each { |key, value| send "#{key}=", value }
    end

    def transactions
      @transactions ||= bank.fetch_transactions_for(self)
    end

    def fetch_transactions(start_date: Date.today - 2.years, end_date: Date.today)
      bank.fetch_transactions_for(self, start_date: start_date, end_date: end_date)
    end

    def currency
      balance.try(:currency)
    end

    private

    def inspect_attributes
      %i(id name balance available_balance description iban bic)
    end
  end
end
