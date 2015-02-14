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

    SAMPLE_WIDTH     = 30
    SAMPLE_HEIGHT    = 30
    SAMPLE_ROOT_PATH = '/ing/numbers'

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

    def balances
      log 'get_balances'
      balances = {}
      total_balance = 0
      @accounts.each do |account|
        balances[account.description] = account.balance
        total_balance += account.balance
      end

      balances['TOTAL'] = total_balance
      balances
    end

    def fetch_accounts
      log 'fetch_accounts'
      set_headers(
        'Accept'       => '*/*',
        'Content-Type' => 'application/json; charset=utf-8'
      )

      @raw_accounts_data = JSON.parse(get(PRODUCTS_ENDPOINT))

      @raw_accounts_data.map do |account|
        build_account(account) if account['iban']
      end.compact
    end

    def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
      log "fetch_transactions for #{account.id}"

      # The API allows any limit to be passed, but we better keep
      # being good API citizens and make a loop with a short limit
      params = {
        fromDate: start_date.strftime('%d/%m/%Y'),
        toDate: end_date.strftime('%d/%m/%Y'),
        limit: 25,
        offset: 0
      }

      transactions = []
      loop do
        request = get("#{PRODUCTS_ENDPOINT}/#{account.id}/movements", params)
        json = JSON.parse(request)
        transactions += json['elements'].map do |transaction|
          build_transaction(transaction, account)
        end
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
      set_headers(
        'Accept'       => 'application/json, text/javascript, */*; q=0.01',
        'Content-Type' => 'application/json; charset=utf-8'
      )

      params = {
        loginDocument: {
          documentType: 0,
          document: @dni.to_s
        },
        birthday: @birthday.to_s,
        companyDocument: nil,
        device: 'desktop'
      }

      response = JSON.parse(post(LOGIN_ENDPOINT, params.to_json))
      current_pinpad_paths = save_pinpad_numbers(response['pinpad'])
      pinpad_numbers = recognize_pinpad_numbers(current_pinpad_paths)

      get_correct_positions(pinpad_numbers, response['pinPositions'])
    end

    def pass_pinpad(positions)
      response = put(LOGIN_ENDPOINT, { pinPositions: positions }.to_json)
      JSON.parse(response)['ticket']
    end

    def post_auth(ticket)
      set_headers(
        'Accept'       => 'application/json, text/javascript, */*; q=0.01',
        'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
      )

      params = "ticket=#{ticket}&device=desktop"
      post(POST_AUTH_ENDPOINT, params)
    end

    def save_pinpad_numbers(pinpad)
      current_pinpad_paths = []
      pinpad.each_with_index do |digit, index|
        tmp = Tempfile.new(["pinpad_number_#{index}", '.png'])
        File.open(tmp.path, 'wb') { |f| f.write(Base64.decode64(digit)) }
        current_pinpad_paths << tmp.path
      end

      current_pinpad_paths
    end

    def recognize_pinpad_numbers(current_pinpad_paths)
      real_numbers = []
      current_numbers = Magick::ImageList.new(*current_pinpad_paths)
      0.upto(9) do |i|
        current_number_img = current_numbers[i]
        pixel_diffs = []
        0.upto(9) do |j|
          sample_number_img = Magick::ImageList.new(sample_number_path(j)).first
          pixel_diffs << images_diff(sample_number_img, current_numbers[i])
        end
        real_numbers << pixel_diffs.each_with_index.min.last
      end
      real_numbers
    end

    def sample_number_path(number)
      File.join(File.dirname(__FILE__), "#{SAMPLE_ROOT_PATH}/#{number}.png")
    end

    def images_diff(sample_number_img, current_number_img)
      diff = 0
      sample_pixels  = pixels_from_coordinates(sample_number_img, 0, 0)
      current_pixels = pixels_from_coordinates(current_number_img, 0, 0)
      current_pixels.each_with_index do |pixel, index|
        sample_pixel = sample_pixels[index]
        red_diff = (pixel.red - sample_pixel.red).abs
        green_diff = (pixel.green - sample_pixel.green).abs
        blue_diff = (pixel.blue - sample_pixel.blue).abs

        diff += red_diff + green_diff + blue_diff
      end

      diff
    end

    def pixels_from_coordinates(img, x, y)
      img.get_pixels(x, y, SAMPLE_WIDTH, SAMPLE_HEIGHT)
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
      amount = Money.new(data['amount'] * 100, data['currency'])
      Transaction.new(
        account: account,
        id: data['uuid'],
        amount: amount,
        currency: data['EUR'],
        effective_date: Date.strptime(data['effectiveDate'], "%d/%m/%Y"),
        description: data['description'],
        balance: data['balance']
      )
    end
  end
end
