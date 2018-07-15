require 'active_support/all'
require 'money'
require 'rubygems'
require_relative 'bankscrap/utils/inspectable'
require_relative 'bankscrap/utils/cli_string'
require_relative 'bankscrap/version'
require_relative 'bankscrap/config'
require_relative 'bankscrap/cli'
require_relative 'bankscrap/bank'
require_relative 'bankscrap/account'
require_relative 'bankscrap/investment'
require_relative 'bankscrap/transaction'
require_relative 'bankscrap/card'
require_relative 'bankscrap/loan'
require_relative 'bankscrap/exporters/csv'
require_relative 'bankscrap/exporters/json'

module Bankscrap
  class << self
    attr_accessor :log
    attr_accessor :debug
    attr_accessor :proxy
  end

  class NotMoneyObjectError < TypeError
    def initialize(attribute)
      super("#{attribute} should be a Money object")
    end
  end

  self.log = false
  self.debug = false
  # self.proxy = { host: 'localhost', port: 8888 }
end
