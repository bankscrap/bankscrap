require 'execjs'
require 'json'
require 'base64'
require 'RMagick'
require 'active_support'
require 'open-uri'

module BankScrap
  class Ing < Bank

    BASE_ENDPOINT = 'https://ing.ingdirect.es/'
    LOGIN_ENDPOINT     = BASE_ENDPOINT + 'genoma_login/rest/session'
    POST_AUTH_ENDPOINT = BASE_ENDPOINT + 'genoma_api/login/auth/response'
    CLIENT_ENDPOINT    = BASE_ENDPOINT + 'genoma_api/rest/client'
    PRODUCTS_ENDPOINT  = BASE_ENDPOINT + 'genoma_api/rest/products'

    SAMPLE_WIDTH  = 30
    SAMPLE_HEIGHT = 30

    def initialize(dni, birthday, password, log: false, debug: false)
      @dni      = dni
      @birthday = birthday
      @password = password.to_s
      @log      = log
      @debug    = debug

      initialize_connection
      bundled_login
      get_products
    end

    def get_balance
      log 'get_balance'
      balance = {}
      @data.each do |item|
        balance[item['name']] = item['balance']
      end

      balance
    end

    private

    def bundled_login
      selected_positions = login
      ticket = pass_pinpad(selected_positions)
      post_auth(ticket)
      remove_generated_files
    end

    def login
      set_headers({
        "Accept"       => 'application/json, text/javascript, */*; q=0.01',
        'Content-Type' => 'application/json; charset=utf-8'
      })

      param = '{' +
                '"loginDocument":{' +
                  '"documentType":0,"document":"' + @dni.to_s +
                '"},' +
                '"birthday":"' + @birthday.to_s + '",' +
                '"companyDocument":null,' +
                '"device":"desktop"}' +
              '}'

      response = post(LOGIN_ENDPOINT, param)
      response = JSON.parse(response)
      positions = response['pinPositions']
      pinpad = response['pinpad']

      save_pinpad_numbers(pinpad)
      pinpad_numbers = recognize_pinpad_numbers

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

    def remove_generated_files
      0.upto(9) do |index|
        File.delete(build_tmp_path(index))
      end
    end

    def get_products
      set_headers({
        "Accept"       => '*/*',
        'Content-Type' => 'application/json; charset=utf-8'
      })

      @data = JSON.parse(get(PRODUCTS_ENDPOINT))
    end

    def save_pinpad_numbers(pinpad)
      pinpad.each_with_index do |p,index|
        File.open(build_tmp_path(index), 'wb'){ |f| f.write(Base64.decode64(p)) }
      end
    end

    def build_tmp_path(number)
      "tmp/original_pinpad_#{number}.png"
    end

    def recognize_pinpad_numbers
      pinpad_numbers = []
      0.upto(9) do |i|
        pinpad = Magick::ImageList.new(build_tmp_path(i)).first

        differences = []
        0.upto(9) do |j|
          pinpad_pixels_sample = pinpad.get_pixels(0,0, SAMPLE_WIDTH, SAMPLE_HEIGHT)

          img = Magick::ImageList.new("lib/banks/ing/numbers/pinpad#{j}.png").first
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
  end
end
