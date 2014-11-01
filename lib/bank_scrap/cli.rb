require 'thor'

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

      bank_class = Object.const_get("BankScrap::" + bank)

      @client = bank_class.new(@user, @password, log: @log, debug: @debug)

      balance = @client.get_balance

      puts "Balance: #{balance}"
    rescue NameError
      puts "Invalid bank: #{bank}"
    end
  end
end
