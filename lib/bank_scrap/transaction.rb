module BankScrap
  class Transaction
    attr_accessor :id, :amount, :currency, 
                  :created_at, :description,
                  :balance
    
    def initialize(params = {})
      params.each { |key, value| send "#{key}=", value }
    end
  end
end

