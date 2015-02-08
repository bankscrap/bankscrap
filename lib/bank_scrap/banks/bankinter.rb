require 'nokogiri'
require 'execjs'

module BankScrap
  class Bankinter < Bank
    BASE_ENDPOINT = "https://www.bankinter.com"
    LOGIN_ENDPOINT = "/www/es-es/cgi/ebk+login"
    TRANSACTIONS_ENDPOINT = "/www/es-es/cgi/ebk+opr+buscadormov"

    def initialize(user, password, log: false, debug: false, extra_args: nil)
      @user = user
      @password = password
      @log = log
      @debug = debug

      initialize_connection
      initialize_cookie(BASE_ENDPOINT)
      parse_html(get(BASE_ENDPOINT + '/www/es-es/cgi/ebk+gc+lgin'))
      login
      super
    end

    def fetch_accounts
      log 'fetch_accounts'
      accounts = []
      if @dashboard_doc
        if links = @dashboard_doc.css('div.caj_content_plegable.bk_ocultable_novisible div.tab_extracto_01')[0]
          links.css('table tbody tr').each do |x|
            name = x.css('td.enlace div form button').text.encode("UTF-8")
            balance_currency = x.css('td.numero').text.scan(/[\d,\.]+|\D+/)
            balance = balance_currency[0]
            currency = balance_currency[1].gsub(/[[:space:]]/,"")
            cc = x.css('td.enlace div form input')[0]['value']
            data = {'id' => cc, 'description' => name, 'availableBalance' => balance, 'currency' => currency, 'iban' => cc}

            accounts.push(build_account(data))
          end
        end
      end

      accounts
    end

    def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
      transactions = []

      fields = {
        'ext-solapa' => 'operar',
        'ext-subsolapa' => 'mis_cuentas',
        'ordenDesc' => '',
        'ordenFechaC' => 'A',
        'ordenFechaV' => '',
        'ordenGasto' => '',
        'ordenIng' => '',
        'buscador' => 'S',
        'tipoConsulta' => 'N',
        'seleccionado_tipo' => '',
        'cuenta_seleccionada' => account.iban,
        'tipoMov' => 'A',
        'dia' => start_date.strftime("%d"),
        'mes' => start_date.strftime("%m"),
        'anio' => start_date.strftime("%Y"),
        'diaH' => end_date.strftime("%d"),
        'mesH' => end_date.strftime("%m"),
        'anioH' => end_date.strftime("%Y"),
      }

      response = post(BASE_ENDPOINT + TRANSACTIONS_ENDPOINT, fields)

      html_doc = Nokogiri::HTML(response)

      html_transactions = html_doc.css('table#tablaDin_tabla tbody tr')

      html_transactions.each do |x|
        date = x.css('td.fecha')[0].text
        description = x.css('td')[2].text
        amount = x.css('td.numero').text.gsub(/\s+|\.|,/, "")

        data = {'description' => description, 'amount' => amount, 'operationDate' => date, 'currency' => account.currency}
        transactions.push(build_transaction(data, account));
      end

      transactions
    end

    private

    def login
      fields = {
        'bkcache' => '',
        'destino' => 'ebk+opr+extractointegral',
        @id_field => 'username,password,psi',
        @login_field => @login_param
      }

      response = post(BASE_ENDPOINT + LOGIN_ENDPOINT, fields)

      response = get(BASE_ENDPOINT + '/www/es-es/cgi/ebk+opr+extractointegral')

      @dashboard_doc = Nokogiri::HTML(response, nil, "ISO-8859-1")
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

    def build_account(data)
      Account.new(
        bank: self,
        id: data['id'],
        balance: data['availableBalance'],
        currency: data['currency'],
        description: data['description'],
        iban: data['iban']
      )  
    end

    def build_transaction(data, account)
      amount = Money.new(data['amount'], data['currency'])
      balance = data['accountBalanceAfterMovement'] ? Money.new(data['accountBalanceAfterMovement'] * 100, data['currency']) : nil

      Transaction.new(
        account: account,
        id: data['id'],
        amount: amount,
        description: data['conceptDescription'] || data['description'],
        effective_date: Date.strptime(data['operationDate'], "%d-%m-%Y"),
        currency: data['currency'],
        balance: balance
      )
    end 
  end
end
