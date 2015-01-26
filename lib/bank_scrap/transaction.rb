module BankScrap
  class Transaction
    attr_accessor :id, :amount, :currency,
                  :effective_date, :description,
                  :balance

    def initialize(params = {})
      params.each{ |key, value| send "#{key}=", value }
    end
  end
end

