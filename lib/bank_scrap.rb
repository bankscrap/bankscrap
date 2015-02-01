require 'active_support/all'
require 'money'
require 'bank_scrap/utils/inspectable'
require 'bank_scrap/version'
require 'bank_scrap/config'
require 'bank_scrap/cli'
require 'bank_scrap/bank'
require 'bank_scrap/account'
require 'bank_scrap/transaction'

module BankScrap
  # autoload only requires the file when the specified
  # constant is used for the first time
  autoload :Bankinter, 'bank_scrap/banks/bankinter'
  autoload :Bbva,      'bank_scrap/banks/bbva'
  autoload :Ing,       'bank_scrap/banks/ing'
end
