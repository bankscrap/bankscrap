module Bankscrap
  class Investment
    include Utils::Inspectable

    attr_accessor :bank, :id, :name, :balance, :currency, :investment

    def initialize(params = {})
      params.each { |key, value| send "#{key}=", value }
    end

    private

    def inspect_attributes
      %i(id name balance currency investment)
    end
  end
end
