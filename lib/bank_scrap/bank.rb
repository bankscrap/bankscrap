module BankScrap
  class Bank

    USER_AGENT = 'Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 4 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19'

    private

    def log(msg)
      puts msg if @debug
    end
  end
end
