require 'thor'
require 'active_support/core_ext/string'

module BankScrap
  class Cli < Thor
    def self.shared_options
      option :user,     default: ENV['BANK_SCRAP_USER']
      option :password, default: ENV['BANK_SCRAP_PASSWORD']
      option :log,      default: false
      option :debug,    default: false

      # Some bank needs more input, like birthday, this would go here
      # Usage:
      # bank_scrap balance BANK_NAME --extra=birthday:01/12/1980
      option :extra, type: :hash
    end

    desc "balance BANK", "get accounts' balance"
    shared_options
    def balance(bank)
      assign_shared_options
      initialize_client_for(bank)

      @client.accounts.each do |account|
        say "Account: #{account.description} (#{account.iban})", :cyan
        say "Balance: #{account.balance}", :green
      end
    end

    # desc "transactions BANK", "get account's transactions"
    # shared_options
    # def transactions(bank)
    #   assign_shared_options
    #   initialize_client_for(bank)
    #   transactions = @client.get_transactions
    # end

    private 

    def assign_shared_options
      @user       = options[:user]
      @password   = options[:password]
      @log        = options[:log]
      @debug      = options[:debug]
      @extra_args = options[:extra]
    end

    def initialize_client_for(bank_name)
      bank_class = find_bank_class_for(bank_name)      
      @client = bank_class.new(@user, @password, log: @log, debug: @debug, extra_args: @extra_args)
    end
    
    def find_bank_class_for(bank_name)
      Object.const_get("BankScrap::" + bank_name.classify)
    rescue NameError
      raise ArgumentError.new('Invalid bank name')
    end

  end
end
