module BankScrap
  class Transaction
    include Utils::Inspectable

    attr_accessor :id, :amount, :currency,
                  :effective_date, :description,
                  :balance, :account

    def initialize(params = {})
      params.each { |key, value| send "#{key}=", value }
    end

    def to_s
      "#{effective_date.strftime('%d/%m/%Y')}   #{description.ljust(45)} #{amount.format.rjust(20)}"
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

