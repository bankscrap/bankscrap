# Bankscrap

Ruby gem to extract balance and transactions from banks. You can use it either as command line tool or as a library.

Feel free to contribute and add your bank if it isn't supported.

## Supported banks
- Bankinter
- BBVA (only balance, transactions soon)

Work in progress:
- ING

Interested in any other bank? Open a new Issue and we'll try to help.
 
## Background and motivation

Most banks don't offer public APIs and the only way to access your data (balance and transactions) is through their websites... and most bank websites are a f*cking nightmare.

We are developers and we don't want to waste time doing things we are able to automate. Having to perform 20 clicks in an awful website just to check how much money we have is not something we like.

There are two approaches to solve this problem: 
- Web scraping on the bank's site.
- Reverse engineering the bank's mobile app to use the same API the app uses.

Bankscrap uses both methods depending on the bank.

## Requirements

Some banks needs a JavaScript runtime in order to work. So if you find an error like "Could not find JavasScript runtime" try to install one. It has been tested with nodejs.

## Installation

### From Git

You can check out the latest source from git:

    git clone git://github.com/ismaGNU/bank_scrap

### From RubyGems

Installation from RubyGems:

    gem install bank_scrap

Or, if you're using Bundler, just add the following to your Gemfile:

    gem 'bank_scrap'

## Usage

### From terminal
Retrieve balance account

    $ bank_scrap balance BANK_NAME --user YOUR_USER --password YOUR_PASSWORD

BANK_NAME should be in underscore case (`bankinter`, `bbva`).

### From Ruby code

You can also use this gem from your own app as library. To do so first you must initialize a Bankscrapper::Bank object

```ruby
require 'bank_scrap'
@bank = BankScrap::Bbva.new(YOUR_BBVA_USER, YOUR_BBVA_PASSWORD)
```

(Replace Bbva with your own bank)

Now you can fetch your balance:

```ruby
@bank.get_balance
```


## Contributing

1. Fork it ( https://github.com/ismaGNU/bank_scrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Thanks to Javier Cuevas (@javiercr) for his Bbva gem.
