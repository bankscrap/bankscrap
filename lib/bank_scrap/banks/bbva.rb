module BankScrap
  class Bbva < Bank
    BASE_ENDPOINT    = 'https://bancamovil.grupobbva.com'
    LOGIN_ENDPOINT   = '/DFAUTH/slod/DFServletXML'
    BALANCE_ENDPOINT = '/ENPP/enpp_mult_web_mobility_02/products/v1'
    USER_AGENT       = 'Android;LGE;Nexus 5;1080x1776;Android;4.4.4;BMES;4.0.4'

    def initialize(user, password, log: false, debug: false)
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
      })

      login
    end

    def get_balance
      log 'get_balance'
      response = post(BASE_ENDPOINT + BALANCE_ENDPOINT, nil)

      json = JSON.parse(response)
      json["balances"]["personalAccounts"]
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