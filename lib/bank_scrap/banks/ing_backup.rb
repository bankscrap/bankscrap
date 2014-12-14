require 'execjs'
require 'pp'
require 'json'
require 'base64'
require 'RMagick'
require 'active_support'
require 'byebug'
require 'open-uri'

module BankScrap
  class Ing < Bank

    DESKTOP_USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.111 Safari/537.36'

    BASE_ENDPOINT           = 'https://ing.ingdirect.es/'
    FALSE_LOGIN_ENDPOINT    = BASE_ENDPOINT + 'login/'
    CACHE_ENDPOINT          = BASE_ENDPOINT + 'login/cache.manifest'
    DELETE_SESSION_ENDPOINT = BASE_ENDPOINT + 'genoma_api/rest/session'
    LOGIN_ENDPOINT          = BASE_ENDPOINT + 'genoma_login/rest/session'
    POST_AUTH_ENDPOINT      = BASE_ENDPOINT + 'genoma_api/login/auth/response'
    CLIENT_ENDPOINT         = BASE_ENDPOINT + 'genoma_api/rest/client'
    PRODUCTS_ENDPOINT       = BASE_ENDPOINT + 'genoma_api/rest/products'

    SAMPLE_WIDTH  = 30
    SAMPLE_HEIGHT = 30

    def initialize(dni, birthday, password, log: false, debug: false)
      @dni      = dni
      @birthday = birthday
      @password = password.to_s
      @log      = log
      @debug    = debug

      initialize_connection

      @curl.proxy_port = 8888
      @curl.proxy_url = '192.168.1.21'

      false_login
      cache
      delete_session
      selected_positions = login

      ticket = pass_pinpad(selected_positions)

      post_auth(ticket)
      call_client

      get_products
    end

    private

    def false_login
      @curl.url = FALSE_LOGIN_ENDPOINT
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @curl.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
      @curl.headers['Accept-Language'] = 'en,es;q=0.8'

      response = @curl.get
    end

    def cache
      @curl.url = CACHE_ENDPOINT
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
      @curl.headers['Accept-Language'] = 'en,es;q=0.8'
    end

    def delete_session
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Pragma'] = 'no-cache'
      @curl.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      @curl.headers['Origin'] = 'https://ing.ingdirect.es'
      @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
      @curl.headers['Content-Type'] = 'application/json; charset=utf-8'
      @curl.headers['Referer'] = 'https://ing.ingdirect.es/login/'
      @curl.headers['Accept-Encoding'] = 'zip,deflate,sdch'
      @curl.headers['Accept-Language'] = 'n,es;q=0.8'
      @curl.headers['Cookie'] = 's_cc=true; s_mca=Direct; s_gts=1; s_nr=1414955726141; s_sq=%5B%5BB%5D%5D'

      response = @curl.delete
      pp response
    end

    def login
      param = '{"loginDocument":{"documentType":0,"document":"' + @dni.to_s +
              '"},"birthday":"' + @birthday.to_s + '","companyDocument":null,"device":"desktop"}'
      puts param
      @curl.url = LOGIN_ENDPOINT
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Pragma'] = 'no-cache'

      @curl.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      @curl.headers['Origin'] = 'https://ing.ingdirect.es'
      @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
      @curl.headers['Content-Type'] = 'application/json; charset=utf-8'
      @curl.headers['Referer'] = 'https://ing.ingdirect.es/login/'
      @curl.headers['Accept-Encoding'] = 'zip,deflate,sdch'
      @curl.headers['Accept-Language'] = 'n,es;q=0.8'
      @curl.headers['Cookie'] = 's_cc=true; s_mca=Direct; s_gts=1; s_nr=1414955726141; s_sq=%5B%5BB%5D%5D'

      response = post(LOGIN_ENDPOINT, param)
      # response = @curl.body_str
      response = JSON.parse(response)
      positions = response['pinPositions']
      pinpad = response['pinpad']

      save_pinpad_numbers(pinpad)
      pinpad_numbers = recognize_pinpad_numbers

      get_correct_positions(pinpad_numbers, positions)
    end

    def pass_pinpad(positions)
      param = "{\"pinPositions\": #{positions}}"
      @curl.url = LOGIN_ENDPOINT
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      @curl.headers['Origin'] = 'https://ing.ingdirect.es'
      @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
      @curl.headers['Content-Type'] = 'application/json; charset=utf-8'
      @curl.headers['Referer'] = 'https://ing.ingdirect.es/login/?clientId=281afde24c938607e5edeac6239e8a38&continue=%2Fpfm%2F'
      @curl.headers['Accept-Encoding'] = 'gzip,deflate,sdch'

      response = put(LOGIN_ENDPOINT, param)
      response = ActiveSupport::Gzip.decompress(response)
      response = JSON.parse(response)

      response['ticket']
    end

    def post_auth(ticket)
        @curl.headers['Host'] = 'ing.ingdirect.es'
        @curl.headers['Connection'] = 'keep-alive'
        @curl.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        @curl.headers['Origin'] = 'https://ing.ingdirect.es'
        @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
        @curl.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        @curl.headers['Referer'] = 'https://ing.ingdirect.es/login'
        @curl.headers['Accept-Encoding'] = 'gzip,deflate'

        @curl.url = POST_AUTH_ENDPOINT
        param = "ticket=#{ticket}&device=desktop"
        @curl.post(param)
        response = @curl.body_str
    end

    def call_client
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
      @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
      @curl.headers['Content-Type'] = 'application/json; charset=utf-8'
      @curl.headers['Referer'] = 'https://ing.ingdirect.es/pfm'
      @curl.headers['Accept-Encoding'] = 'gzip,deflate,sdch'

      response = get(CLIENT_ENDPOINT)

      response = ActiveSupport::Gzip.decompress(response)
      response = JSON.parse(response)
    end

    def get_products
      @curl.headers['Host'] = 'ing.ingdirect.es'
      @curl.headers['Connection'] = 'keep-alive'
      @curl.headers['Accept'] = '*/*'
      @curl.headers['X-Requested-With'] = 'XMLHttpRequest'
      @curl.headers['Content-Type'] = 'application/json; charset=utf-8'
      @curl.headers['Referer'] = 'https://ing.ingdirect.es/pfm'
      @curl.headers['Accept-Encoding'] = 'gzip,deflate,sdch'

      response = get(PRODUCTS_ENDPOINT)

      File.open('response_raw.txt', 'w') { |file| file.write(response) }
      response = ActiveSupport::Gzip.decompress(response)
      File.open('response_decompressed.txt', 'w') { |file| file.write(response) }
      File.open('response_parsed.txt', 'w') { |file| file.write(JSON.parse(response)) }
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

          img = Magick::ImageList.new("numbers/pinpad#{j}.png").first
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