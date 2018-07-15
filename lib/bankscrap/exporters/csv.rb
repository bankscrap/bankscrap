require 'csv'
require 'thor'

module BankScrap
  module Exporter
    # Csv exporter
    class Csv
      def initialize(account)
        @account = account
      end

      def get_filename(data, output)
        unless output
          if check_array_class(data, Bankscrap::Transaction)
            return 'transactions.json'
          elsif check_array_class(data, Bankscrap::Account)
            return 'accounts.json'
          elsif check_array_class(data, Bankscrap::Loan)
            return 'loans.json'
          elsif check_array_class(data, Bankscrap::Card)
            return 'cards.json'
          end
        else
          if output == '-'
            return '/dev/stdout'
          else
            return output
          end
        end
      end

      def check_array_class(data, tclass)
        data.all? { |x| x.is_a? tclass }
      end

      def write_to_file(data, output)
        output = get_filename(data, output)
        if check_array_class(data, Bankscrap::Transaction)
          CSV.open(output, 'wb') do |csv|
            csv << %w(Date Description Amount)
            data.each { |line| csv << line.to_a }
          end
          STDERR.puts "Transactions for: #{@account.description} (#{@account.iban}) exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Account)
          CSV.open(output, 'wb') do |csv|
            csv << %w(Id Iban Name Description Bank Balance)
            data.each { |line| csv << line.to_a }
          end
          STDERR.puts "Accounts exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Loan)
          CSV.open(output, 'wb') do |csv|
            csv << %w(Id Name Description Amount)
            data.each { |line| csv << line.to_a }
          end
          STDERR.puts "Accounts exported to #{output}".cyan
        elsif check_array_class(data, Bankscrap::Card)
          CSV.open(output, 'wb') do |csv|
            csv << %w(Id Name Description Pan Amount Avaliable Is_credit)
            data.each { |line| csv << line.to_a }
          end
          STDERR.puts "Accounts exported to #{output}".cyan
        end
      end
    end
  end
end
