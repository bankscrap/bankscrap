require 'json'
require 'base64'
require 'RMagick'
require 'tempfile'

module BankScrap
  class Ing < Bank

    BASE_ENDPOINT = 'https://ing.ingdirect.es/'
    LOGIN_ENDPOINT     = BASE_ENDPOINT + 'genoma_login/rest/session'
    POST_AUTH_ENDPOINT = BASE_ENDPOINT + 'genoma_api/login/auth/response'
    CLIENT_ENDPOINT    = BASE_ENDPOINT + 'genoma_api/rest/client'
    PRODUCTS_ENDPOINT  = BASE_ENDPOINT + 'genoma_api/rest/products'

    SAMPLE_WIDTH  = 30
    SAMPLE_HEIGHT = 30

    def initialize(user, password, log: false, debug: false, extra_args:)
      @dni      = user
      @password = password.to_s
      @birthday = extra_args.with_indifferent_access['birthday']
      @log      = log
      @debug    = debug

      initialize_connection
      bundled_login

      super
    end

    def get_balance
      log 'get_balance'
      balances = {}
      total_balance = 0
      @accounts.each do |account|
        balances[account.description] = account.balance
        total_balance += account.balance
      end

      balances['TOTAL'] = total_balance
      balances
    end

    def raw_accounts_data
      @raw_accounts_data
    end

    def fetch_accounts
      log 'fetch_accounts'
      set_headers({
        "Accept"       => '*/*',
        'Content-Type' => 'application/json; charset=utf-8'
      })

      @raw_accounts_data = JSON.parse(get(PRODUCTS_ENDPOINT))

      @raw_accounts_data.collect do |account|
        if account['iban']
          build_account(account)
        end
      end.compact
    end

    def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
      log "fetch_transactions for #{account.id}"

      # The API allows any limit to be passed, but we better keep
      # being good API citizens and make a loop with a short limit
      params = {
        fromDate: start_date.strftime("%d/%m/%Y"),
        toDate: end_date.strftime("%d/%m/%Y"),
        limit: 25, 
        offset: 0
      }

      transactions = []
      loop do
        request = get("#{PRODUCTS_ENDPOINT}/#{account.id}/movements", params)
        json = JSON.parse(request)
        transactions += json['elements'].collect { |transaction| build_transaction(transaction, account) }
        params[:offset] += 25
        break if (params[:offset] > json['total']) || json['elements'].blank?
      end
      transactions
    end

    private

    def bundled_login
      selected_positions = login
      ticket = pass_pinpad(selected_positions)
      post_auth(ticket)
    end

    def login
      set_headers({
        "Accept"       => 'application/json, text/javascript, */*; q=0.01',
        'Content-Type' => 'application/json; charset=utf-8'
      })

      param = {
        loginDocument: {
          documentType: 0,
          document: @dni.to_s
        },
        birthday: @birthday.to_s,
        companyDocument: nil,
        device: 'desktop'
      }

      response = JSON.parse(post(LOGIN_ENDPOINT, param.to_json))
      positions = response['pinPositions']
      pinpad    = response['pinpad']

      pinpad_numbers_paths = save_pinpad_numbers(pinpad)
      pinpad_numbers = recognize_pinpad_numbers(pinpad_numbers_paths)

      get_correct_positions(pinpad_numbers, positions)
    end

    def pass_pinpad(positions)
      set_headers({
          "Accept"       => 'application/json, text/javascript, */*; q=0.01',
          'Content-Type' => 'application/json; charset=utf-8'
        })

      param = "{\"pinPositions\": #{positions}}"
      response = put(LOGIN_ENDPOINT, param)
      JSON.parse(response)['ticket']
    end

    def post_auth(ticket)
        set_headers({
          "Accept"       => 'application/json, text/javascript, */*; q=0.01',
          'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
        })

        param = "ticket=#{ticket}&device=desktop"
        post(POST_AUTH_ENDPOINT, param)
    end

    def save_pinpad_numbers(pinpad)
      pinpad_numbers_paths = []
      pinpad.each_with_index do |digit,index|
        tmp = Tempfile.new(["pinpad_number_#{index}", '.png'])
        File.open(tmp.path, 'wb'){ |f| f.write(Base64.decode64(digit)) }
        pinpad_numbers_paths << tmp.path
      end

      pinpad_numbers_paths
    end

    def recognize_pinpad_numbers(pinpad_numbers_paths)
      pinpad_numbers = []
      pinpad_images = Magick::ImageList.new(*pinpad_numbers_paths)
      0.upto(9) do |i|
        single_number = pinpad_images[i]
        differences = []
        0.upto(9) do |j|
          pinpad_pixels_sample = single_number.get_pixels(0,0, SAMPLE_WIDTH, SAMPLE_HEIGHT)

          img = Magick::ImageList.new(File.join(File.dirname(__FILE__), "/ing/numbers/pinpad#{j}.png")).first
          number_pixels_sample = img.get_pixels(0, 0, SAMPLE_WIDTH, SAMPLE_HEIGHT)
          diff = 0
          pinpad_pixels_sample.each_with_index do |pixel, index|
            sample_pixel = number_pixels_sample[index]
            diff += (pixel.red - sample_pixel.red).abs +
                    (pixel.green - sample_pixel.green).abs +
                    (pixel.blue - sample_pixel.blue).abs
          end
          differences << diff
        end

        real_number = differences.each_with_index.min.last
        pinpad_numbers << real_number
      end

      pinpad_numbers
    end

    def get_correct_positions(pinpad_numbers, positions)
      first_digit  = @password[positions[0] - 1]
      second_digit = @password[positions[1] - 1]
      third_digit  = @password[positions[2] - 1]

      [
        pinpad_numbers.index(first_digit.to_i),
        pinpad_numbers.index(second_digit.to_i),
        pinpad_numbers.index(third_digit.to_i)
      ]
    end

    # Build an Account object from API data
    def build_account(data)
      Account.new(
        bank: self,
        id: data['uuid'],
        name: data['name'],
        balance: data['balance'],
        currency: 'EUR',
        available_balance: data['availableBalance'],
        description: (data['alias'] || data['name']),
        iban: data['iban'],
        bic: data['bic']
      )
    end

    # Build a transaction object from API data
    def build_transaction(data, account)
      Transaction.new(
        account: account,
        id: data['uuid'],
        amount: data['amount'],
        currency: data['EUR'],
        effective_date: data['effectiveDate'],
        description: data['description'],
        balance: data['balance']
      )
    end
  end
end
