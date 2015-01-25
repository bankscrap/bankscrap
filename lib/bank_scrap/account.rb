module BankScrap
  class Account
    attr_accessor :bank, :id, :name, :balance, :currency, 
                  :available_balance, :description,
                  :transactions, :iban, :bic
    
    def initialize(params = {})
      params.each { |key, value| send "#{key}=", value }
    end

    def transactions
      @transactions ||= bank.fetch_transactions_for(self)
    end
  end
end

