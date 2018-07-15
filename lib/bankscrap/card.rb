module Bankscrap
  class Card
    include Utils::Inspectable

    attr_accessor :bank, :id, :name, :pan, :amount,
                  :avaliable, :is_credit, :description,
                  :raw_data

    def initialize(params = {})
      raise NotMoneyObjectError.new(:amount) unless params[:amount].is_a?(Money)
      raise NotMoneyObjectError.new(:avaliable) unless params[:avaliable].is_a?(Money)

      params.each { |key, value| send "#{key}=", value }
    end

    def currency
      amount.try(:currency)
    end

    def to_s
      description
    end

    def to_a
      [id, name, description, pan, amount, avaliable, is_credit]
    end

    private

    def inspect_attributes
      %i(id name description pan amount avaliable is_credit)
    end
  end
end
