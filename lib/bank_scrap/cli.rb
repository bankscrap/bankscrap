require 'thor'
require 'active_support/core_ext/string'

module BankScrap
  class Cli < Thor

    desc "balance BANK", "get account's balance"
    option :user, default: ENV['USER']
    option :password,  default: ENV['PASSWORD']
    option :log, default: false
    option :debug, default: false
    def balance(bank)
      @user = options[:user]
      @password = options[:password]
      @log = options[:log]
      @debug = options[:debug]

      bank_class = find_bank_class_for(bank)      
      @client = bank_class.new(@user, @password, log: @log, debug: @debug)

      balance = @client.get_balance
      puts "Balance: #{balance}"
    end

    desc "transactions BANK", "get account's transactions"
    option :user, default: ENV['USER']
    option :password,  default: ENV['PASSWORD']
    option :log, default: false
    option :debug, default: false
    def transactions(bank)
      @user = options[:user]
      @password = options[:password]
      @log = options[:log]
      @debug = options[:debug]

      bank_class = find_bank_class_for(bank)      
      @client = bank_class.new(@user, @password, log: @log, debug: @debug)

      transactions = @client.get_transactions
    end

    private 
    
    def find_bank_class_for(bank_name)
      Object.const_get("BankScrap::" + bank_name.classify)
    rescue NameError
      raise ArgumentError.new('Invalid bank name')
    end
  end
end
