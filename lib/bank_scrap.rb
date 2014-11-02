require 'bank_scrap/version'
require 'bank_scrap/cli'
require 'bank_scrap/bank'

module BankScrap
  # autoload only requires the file when the specified
  # constant is used for the first time
  autoload :Bankinter,  'bank_scrap/banks/bankinter'
  autoload :Bbva,       'bank_scrap/banks/bbva'
end
