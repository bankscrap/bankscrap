require 'thor'
require 'active_support/core_ext/string'
Dir[File.expand_path('../../..', __FILE__) + '/generators/*.rb'].each do |generator|
  require generator
end

module Bankscrap
  class CLI < Thor
    SPACER = (' ' * 3).freeze

    def self.shared_options
      option :credentials, default: {}, type: :hash
      option :log,         default: false, type: :boolean
      option :debug,       default: false, type: :boolean
      option :iban,        default: nil
      option :format
      option :output
    end

    desc 'balance BankName', "get account's balance"
    shared_options
    def balance(bank)
      assign_shared_options
      initialize_client_for(bank)

      if options[:format]
        export_to_file(nil, @client.accounts, options[:format], options[:output])
      else
        @client.accounts.each do |account|
          STDERR.puts "Account: #{account.description} (#{account.iban})".cyan
          STDERR.puts "Balance: #{account.balance.format}".green
          if account.balance != account.available_balance
            STDERR.puts "Available: #{account.available_balance.format}".yellow
          end
        end
      end
    end

    desc 'cards BankName', "get account's credit cards"
    shared_options
    def cards(bank)
      assign_shared_options
      initialize_client_for(bank)

      if options[:format]
        export_to_file(nil, @client.cards, options[:format], options[:output])
      else
        @client.cards.each do |card|
           STDERR.puts "Card: #{card.name} #{card.description} #{card.amount.format}".green
        end
      end
    end

    desc 'loans BankName', "get account's loans"
    shared_options
    def loans(bank)
      assign_shared_options
      initialize_client_for(bank)

      if options[:format]
        export_to_file(nil, @client.loans, options[:format], options[:output])
      else
        @client.loans.each do |loan|
          STDERR.puts "Loan: #{loan.name} #{loan.description} #{loan.amount.format}".green
        end
      end
    end

    desc 'transactions BankName', "get account's transactions"
    shared_options
    options from: :string, to: :string
    def transactions(bank)
      assign_shared_options

      start_date = parse_date(options[:from]) if options[:from]
      end_date = parse_date(options[:to]) if options[:to]

      initialize_client_for(bank)

      account = @iban ? @client.account_with_iban(@iban) : @client.accounts.first

      if start_date && end_date
        if start_date > end_date
          STDERR.puts 'From date must be lower than to date'.red
          exit
        end

        transactions = account.fetch_transactions(start_date: start_date, end_date: end_date)
      else
        transactions = account.transactions
      end

      if options[:format]
        export_to_file(account, transactions, options[:format], options[:output])
      else
        STDERR.puts "Transactions for: #{account.description} (#{account.iban})".cyan
        print_transactions_header
        transactions.each { |t| print_transaction(t) }
      end
    end

    register(Bankscrap::AdapterGenerator, 'generate_adapter', 'generate_adapter MyBankName',
             'generates a template for a new Bankscrap bank adapter')

    private

    def assign_shared_options
      @credentials  = options[:credentials]
      @iban         = options[:iban]
      @log          = options[:log]
      @debug        = options[:debug]
    end

    def initialize_client_for(bank_name)
      bank_class = find_bank_class_for(bank_name)
      Bankscrap.log = @log
      Bankscrap.debug = @debug
      @client = bank_class.new(@credentials)
    end

    def find_bank_class_for(bank_name)
      require "bankscrap-#{bank_name.underscore.dasherize}"
      Object.const_get("Bankscrap::#{bank_name}::Bank")
    rescue LoadError
      raise ArgumentError.new('Invalid bank name.')
    rescue NameError
      raise ArgumentError.new("Invalid bank name. Did you mean \"#{bank_name.upcase}\"?")
    end

    def parse_date(string)
      Date.strptime(string, '%d-%m-%Y')
    rescue ArgumentError
      STDERR.puts 'Invalid date format. Correct format d-m-Y (eg: 31-12-2016)'.red
      exit
    end

    def export_to_file(account, data, format, path)
      exporter(account, format).write_to_file(data, path)
    end

    def exporter(account, format)
      case format.downcase
      when 'csv'
        exporter = BankScrap::Exporter::Csv
      when 'json'
        exporter = BankScrap::Exporter::Json
      else
        STDERR.puts 'Sorry, file format not supported.'.red
        exit
      end
      exporter.new(account)
    end

    def print_transactions_header
       STDERR.puts "\n"
       STDERR.puts 'DATE'.ljust(13)
       STDERR.puts 'DESCRIPTION'.ljust(50) + SPACER
       STDERR.puts 'AMOUNT'.rjust(15) + SPACER
       STDERR.puts 'BALANCE'.rjust(15)
       STDERR.puts '-' * 99
    end

    def print_transaction(transaction)
      color = (transaction.amount.to_i > 0 ? :green : :red)
      STDERR.puts transaction.effective_date.strftime('%d/%m/%Y') + SPACER
      STDERR.puts Utils::CliString.new(transaction.description).squish.truncate(50).ljust(50) + SPACER.colorize(color)
      STDERR.puts Utils::CliString.new(transaction.amount.format).rjust(15) + SPACER.colorize(color)
      STDERR.puts Utils::CliString.new(transaction.balance.format).rjust(15)
    end
  end
end
