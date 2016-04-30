require 'thor'
require 'active_support/core_ext/string'

module Bankscrap
  class CLI < Thor
    def self.shared_options
      option :user,     default: ENV['BANKSCRAP_USER']
      option :password, default: ENV['BANKSCRAP_PASSWORD']
      option :log,      default: false
      option :debug,    default: false

      # Some bank needs more input, like birthday, this would go here
      # Usage:
      # bankscrap balance BANK_NAME --extra=birthday:01/12/1980
      option :extra, type: :hash, default: {}
    end

    desc 'balance BANK', "get accounts' balance"
    shared_options
    def balance(bank)
      assign_shared_options
      initialize_client_for(bank)

      @client.accounts.each do |account|
        say "Account: #{account.description} (#{account.iban})", :cyan
        say "Balance: #{account.balance}", :green
      end
    end

    desc 'transactions BANK', "get account's transactions"
    shared_options
    options from: :string, to: :string
    def transactions(bank, iban = nil)
      assign_shared_options
      start_date = Date.strptime(options[:from], '%d-%m-%Y') if options[:from] 
      end_date = Date.strptime(options[:to], '%d-%m-%Y') if options[:to]

      initialize_client_for(bank)

      account = iban ? @client.account_with_iban(iban) : @client.accounts.first

      if start_date && end_date
        if start_date > end_date
          say 'From date must be lower than to date', :red
          exit
        end

        transactions = account.fetch_transactions(start_date: start_date, end_date: end_date)
      else
        transactions = account.transactions
      end

      say "Transactions for: #{account.description} (#{account.iban})", :cyan

      transactions.each do |transaction|
        say transaction.to_s, (transaction.amount > Money.new(0) ? :green : :red)
      end
    rescue ArgumentError
      say 'Invalid date format. Correct format d-m-Y (eg: 31-12-2016)', :red
    end

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
      require "bankscrap-#{bank_name.downcase}"
      Object.const_get("Bankscrap::#{bank_name}::Bank")
    rescue LoadError
      raise ArgumentError.new('Invalid bank name.')
    rescue NameError
      raise ArgumentError.new("Invalid bank name. Did you mean \"#{bank_name.upcase}\"?")
    end
  end
end
