module Bankscrap
  class Transaction
    include Utils::Inspectable

    class InvalidAmount < ArgumentError; end

    attr_accessor :id, :amount, :description,
                  :balance, :account

    def initialize(params = {})
      unless params[:amount].is_a?(Money)
        raise InvalidAmount.new('amount should be a Money object')
      end

      params.each { |key, value| send "#{key}=", value }
    end

    def to_s
      "#{effective_date.strftime('%d/%m/%Y')}   #{description.ljust(45)} #{amount.format.rjust(20)}"
    end

    def to_a
      [effective_date.strftime('%d/%m/%Y'), description, amount]
    end

    def currency
      amount.currency
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
