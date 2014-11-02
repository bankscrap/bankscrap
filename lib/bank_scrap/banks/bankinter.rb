require 'nokogiri'
require 'execjs'

module BankScrap
  class Bankinter < Bank

    BASE_ENDPOINT = "https://movil.bankinter.es"
    LOGIN_ENDPOINT = "/mov/es-es/cgi/ebkmovil+md+login"

    def initialize(user, password, log: false, debug: false)
      @user = user
      @password = password
      @log = log
      @debug = debug

      initialize_connection
      parse_html(initialize_cookie(BASE_ENDPOINT + '/'))
      login
    end

    def get_balance
      if @dashboard_doc
        if links = @dashboard_doc.css('div.textoresaltado_md a')
          links[0].text
        end
      end
    end

    def get_transactions
      response = get(BASE_ENDPOINT + "/mov/es-es/cgi/" + @transactions_endpoint)

      html_doc = Nokogiri::HTML(response)

      html_transactions = html_doc.css('ul#listamovimiento li')

      # puts html_transactions[0]
      html_transactions.each do |x| 
        puts x.css('div.fechaimagen span').text
        puts x.css('div.altoMaximo').text
        puts x.css('div.importesproductosflecha_md').text
      end

    end

    private

    def login
      fields = [
          Curl::PostField.content('bkcache',''),
          Curl::PostField.content('destino', ''),
          Curl::PostField.content(@id_field, 'username,password,psi'),
          Curl::PostField.content(@login_field,@login_param)
      ]

      response = post(BASE_ENDPOINT + LOGIN_ENDPOINT, fields)

      @dashboard_doc = Nokogiri::HTML(response)

      @transactions_endpoint = @dashboard_doc.xpath('//div[@class="floatIzquierdo_md"]/form/@action')[0];

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
  end
end
