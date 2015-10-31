module BankScrap
  # Default format for money: 1.000,00 €
  Money.default_formatting_rules = { symbol_position: :after }
  I18n.load_path += Dir.glob(File.expand_path('../locale/*.yml', __FILE__))
end
