module Bankscrap
  class Loan
    include Utils::Inspectable

    attr_accessor :bank, :id, :name, :amount,
                  :description,
                  :raw_data

    def initialize(params = {})
      raise NotMoneyObjectError.new(:amount) unless params[:amount].is_a?(Money)

      params.each { |key, value| send "#{key}=", value }
    end

    def currency
      amount.try(:currency)
    end

    def to_s
      description
    end

    def to_a
      [id, name, description, amount]
    end

    private

    def inspect_attributes
      %i(id name description amount)
    end
  end
end
