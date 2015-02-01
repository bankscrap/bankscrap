module BankScrap
  class Account
    include Utils::Inspectable

    attr_accessor :bank, :id, :name, :balance, :currency,
                  :available_balance, :description,
                  :transactions, :iban, :bic

    def initialize(params = {})
      params.each { |key, value| send "#{key}=", value }
    end

    def transactions
      @transactions ||= bank.fetch_transactions_for(self)
    end

    def fetch_transactions(start_date: Date.today - 2.years, end_date: Date.today)
      bank.fetch_transactions_for(self, start_date: start_date, end_date: end_date)
    end

    private

    def inspect_attributes
      [
        :id, :name, :balance, :currency,
        :available_balance, :description,
        :iban, :bic
      ]
    end
  end
end

