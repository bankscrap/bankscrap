module BankScrap
  class Transaction
    include Utils::Inspectable

    attr_accessor :id, :amount, :currency,
                  :effective_date, :description,
                  :balance, :account

    def initialize(params = {})
      params.each{ |key, value| send "#{key}=", value }
    end

    private

    def inspect_attributes
      [
        :id, :amount, :currency,
        :effective_date, :description,
        :balance
      ]
    end

  end
end

