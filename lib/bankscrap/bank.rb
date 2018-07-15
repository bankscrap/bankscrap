require 'mechanize'
require 'logger'

module Bankscrap
  class Bank
    WEB_USER_AGENT = 'Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 4 Build/JOP40D) AppleWebKit/535.19 (KHTML, ' \
                     'like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19'.freeze
    attr_accessor :headers, :accounts, :cards, :loans, :investments

    REQUIRED_CREDENTIALS = %i(user password).freeze

    class MissingCredential < ArgumentError; end

    def initialize(credentials = {})
      # Assign required credentials as env vars.
      # If empty, use ENV vars as fallback:
      # BANKSCRAP_MY_BANK_USER, BANKSCRAP_MY_BANK_PASWORD, etc.
      self.class::REQUIRED_CREDENTIALS.each do |field|
        value = credentials.with_indifferent_access[field] || ENV["#{env_vars_prefix}_#{field.upcase}"]
        raise MissingCredential, "Missing credential: '#{field}'" if value.blank?
        instance_variable_set("@#{field}", value)
      end

      initialize_http_client

      # Bank adapters should use the yield block to do any required processing of credentials
      yield if block_given?

      login
      @accounts = fetch_accounts
      @loans = fetch_loans
      @cards = fetch_cards

      # Not all the adapters have support for investments
      @investments = fetch_investments if respond_to?(:fetch_investments)
    end

    # Interface method placeholders

    def login
      raise "#{self.class} should implement a login method"
    end

    def fetch_accounts
      raise "#{self.class} should implement a fetch_account method"
    end

    def fetch_cards
      raise "#{self.class} should implement a fetch_card method"
    end

    def fetch_loans
      raise "#{self.class} should implement a fetch_loan method"
    end

    def fetch_transactions_for(*)
      raise "#{self.class} should implement a fetch_transactions method"
    end

    def account_with_iban(iban)
      accounts.find do |account|
        account.iban.delete(' ') == iban.delete(' ')
      end
    end

    private

    def get(url, params: [], referer: nil)
      @http.get(url, params, referer, @headers).body
    end

    def post(url, fields: {})
      @http.post(url, fields, @headers).body
    end

    def put(url, fields: {})
      @http.put(url, fields, @headers).body
    end

    # Sets temporary HTTP headers, execute a code block
    # and resets the headers
    def with_headers(tmp_headers)
      current_headers = @headers
      add_headers(tmp_headers)
      yield
    ensure
      add_headers(current_headers)
    end

    def add_headers(headers)
      @headers.merge! headers
      @http.request_headers = @headers
    end

    def initialize_cookie(url)
      @http.get(url).body
    end

    def initialize_http_client
      @http = Mechanize.new do |mechanize|
        mechanize.user_agent = WEB_USER_AGENT
        mechanize.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        mechanize.log = Logger.new(STDOUT) if Bankscrap.debug

        if Bankscrap.proxy
          mechanize.set_proxy Bankscrap.proxy[:host], Bankscrap.proxy[:port]
        end
      end

      @headers = {}
    end

    def log(msg)
      puts msg if Bankscrap.log
    end

    # Prefix for env vars used to store credentials
    def env_vars_prefix
      self.class.parent.name.underscore.upcase.tr('/', '_')
    end
  end
end
