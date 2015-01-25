require 'json'

module BankScrap
  class Bbva < Bank
    BASE_ENDPOINT    = 'https://bancamovil.grupobbva.com'
    LOGIN_ENDPOINT   = '/DFAUTH/slod/DFServletXML'
    PRODUCTS_ENDPOINT = '/ENPP/enpp_mult_web_mobility_02/products/v1'
    # BBVA expects an identifier before the actual User Agent, but 12345 works fine
    USER_AGENT       = '12345;Android;LGE;Nexus 5;1080x1776;Android;4.4.4;BMES;4.0.4'

    def initialize(user, password, log: false, debug: false, extra_args: nil)
      @user = format_user(user.dup)
      @password = password
      @log = log
      @debug = debug

      initialize_connection

      set_headers({
        "User-Agent"       => USER_AGENT,
        'BBVA-User-Agent'  => USER_AGENT,
        'Accept-Language'  => 'spa',
        'Content-Language' => 'spa',
        'Accept'           => 'application/json',
        'Accept-Charset'   => 'UTF-8',
        'Connection'       => 'Keep-Alive',
        'Host'             => 'bancamovil.grupobbva.com',
        'Cookie2'          => '$Version=1'
      })

      login
      super
    end

    def fetch_accounts
      log 'fetch_accounts'
      
      # Even if the required method is an HTTP POST
      # the API requires a funny header that says is a GET
      # otherwise the request doesn't work.
      response = with_headers({'BBVA-Method' => 'GET'}) do
        post(BASE_ENDPOINT + PRODUCTS_ENDPOINT, {})
      end

      json = JSON.parse(response)
      json["accounts"].collect do |data|
        Account.new(
          bank: self,
          id: data['id'],
          name: data['name'],
          available_balance: data['availableBalance'],
          balance: data['availableBalance'],
          currency: data['currency'],
          iban: data['iban'],
          description: "#{data['typeDescription']} #{data['familyCode']}"
        )  
      end
    end

    
    private 

    # As far as we know there are two types of identifiers BBVA uses
    # 1) A number of 7 characters that gets passed to the API as it is
    # 2) A DNI number, this needs to transformed before it get passed to the API
    #    Example: "49021740T" will become "0019-049021740T"
    def format_user(user)
      user.upcase!
      
      if user.match /^[0-9]{8}[A-Z]$/ 
        # It's a DNI
        "0019-0#{user}"
      else
        user
      end 
    end

    def login
      log 'login'
      post(BASE_ENDPOINT + LOGIN_ENDPOINT, {
        'origen'         => 'enpp',
        'eai_tipoCP'     => 'up',
        'eai_user'       => @user,
        'eai_password'   => @password,
        'eai_URLDestino' => '/ENPP/enpp_mult_web_mobility_02/sessions/v1'
      })
    end
  end
end