require 'json'
require 'colorize'

module BankScrap
  module Exporter
    # Json exporter
    class Json
      def initialize(account)
        @account = account
      end

      def get_filename(data, output)
        if output
          if output == '-'
            '/dev/stdout'
          else
            output
          end
        else
          if check_array_class(data, Bankscrap::Transaction)
            'transactions.json'
          elsif check_array_class(data, Bankscrap::Account)
            'accounts.json'
          elsif check_array_class(data, Bankscrap::Loan)
            'loans.json'
          elsif check_array_class(data, Bankscrap::Card)
            'cards.json'
          end
        end
      end

      def check_array_class(data, tclass)
        data.all? { |x| x.is_a? tclass }
      end

      def write_to_file(data, output)
        output = get_filename(data, output)
        json_array = []
        if check_array_class(data, Bankscrap::Transaction)
          data.each do |line|
            array = line.to_a
            hash = { date: array[0], description: array[1], amount: array[2] }
            json_array << hash
          end
          json_hash = { account: { description: @account.description, iban: @account.iban }, transactions: json_array }
        elsif check_array_class(data, Bankscrap::Account)
          data.each do |line|
            array = line.to_a

            hash = { iban: array[1], name: array[2], description: array[3], amount: array[4] }
            json_array << hash
          end

          json_hash = { accounts: json_array }
        elsif check_array_class(data, Bankscrap::Loan)
          data.each do |line|
            array = line.to_a

            hash = { id: array[0], name: array[1], description: array[2], amount: array[3] }
            json_array << hash
          end

          json_hash = { loans: json_array }
        elsif check_array_class(data, Bankscrap::Card)
          data.each do |line|
            array = line.to_a

            hash = { id: array[0], name: array[1], description: array[2], pan: array[3], amount: array[4], avaliable: array[5], isCredit: array[6] }
            json_array << hash
          end

          json_hash = { cards: json_array }
        end
        File.open(output, 'w') do |f|
          f.write(JSON.pretty_generate(json_hash) + "\n")
        end
        if check_array_class(data, Bankscrap::Transaction)
          STDERR.puts "Transactions for: #{@account.description} (#{@account.iban}) exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Account)
          STDERR.puts "Accounts exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Loan)
          STDERR.puts "Loans exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Card)
          STDERR.puts "Cards exported to #{output}".cyan
        end
      end
    end
  end
end
