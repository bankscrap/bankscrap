require 'faraday'
require 'faraday-cookie_jar'
require 'faraday_middleware'
require 'nokogiri'
require 'execjs'

class Bankinter

  BASE_ENDPOINT = "https://movil.bankinter.es"
  LOGIN_ENDPOINT = "/mov/es-es/cgi/ebkmovil+md+login"

  def initialize(user, password, debug: false)
    @user = user
    @password = password
    @debug = debug

    initialize_connection
    initialize_cookie
    login 
  end

  def get_balance
    if @dashboard_doc
      if links = @dashboard_doc.css('div.textoresaltado_md a')
        links[0].text
      end
    end
  end

  private

  def login
    log 'Bankinter login'

    response = @connection.post LOGIN_ENDPOINT, {
      :bkcache => '',
      :destino => '',
      @id_field => 'username,password,psi',
      @login_field => @login_param
    }

    @dashboard_doc = Nokogiri::HTML(response.body)

    #TODO: Check for sucessfull login
  end

  def initialize_cookie
    log "Initializing cookie"
    response = @connection.get '/'

    parse_html(response.body)
  end

  def parse_html(html)
    log 'Parsing Html'

    html_doc = Nokogiri::HTML(html)

    html_form = html_doc.css('form#fLogSecurity')
    #TODO: Check if form is present if not retry initialize cookie for 5 attemps

    @id_field = html_form.xpath('input[3]/@id')

    js_source = 'var document = {};' + html_form.text

    @login_field = js_source.match('eval\(doc_Login\+\'(.+)\'\+')[1]

    js_function = js_source.match('sty_Login\)\.value=(.+)\(')[1]

    server_id = js_source.match('Array\((.+),')[1]

    js_context = ExecJS.compile(js_source)
    psi_actions = 'S(' + (Time.now.to_f * 1000).to_i.to_s + ')S(12946;server:' + server_id.to_i(16).to_s + ')'

    @login_param = js_context.call(js_function, @user, @password, psi_actions)
  end

  def initialize_connection
    @connection = Faraday.new(url: BASE_ENDPOINT) do |faraday|
      faraday.request :url_encoded
      faraday.use :cookie_jar
      faraday.use FaradayMiddleware::FollowRedirects, limit: 3
      faraday.adapter Faraday.default_adapter
    end

    @connection.headers[:user_agent] = 'Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 4 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19'
  end

  def log(msg)
    puts msg if @debug
  end
end
