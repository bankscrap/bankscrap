# Bankscrap

[![](http://188.166.39.57:3000/badge.svg)](http://188.166.39.57:3000)

Ruby gem to extract account balance and transactions from banks. You can use it either as command line tool or as a library.

Feel free to contribute and add your bank if it isn't supported.

## Supported banks

* **BBVA**: [bankscrap-bbva](https://github.com/bankscrap/bankscrap-bbva)
* **ING Direct**: [bankscrap-ing](https://github.com/bankscrap/bankscrap-ing)
* **Banc Sabadell** (WIP): [bankscrap-banc-sabadell](https://github.com/bankscrap/bankscrap-banc-sabadell)

Interested in any other bank? Open a new Issue and we'll try to help.

## Background and motivation

Most banks don't offer public APIs and the only way to access your data (balance and transactions) is through their websites... and most bank websites are a f*cking nightmare.

We are developers and we don't want to waste time doing things we are able to automate. Having to perform 20 clicks in an awful website just to check how much money we have is not something we like.

There are two approaches to solve this problem:
- Web scraping on the bank's site.
- Reverse engineering the bank's mobile app or the bank's single page web app (if they have one) to use the same API.

BankScrap uses both methods depending on the bank.

## Requirements

Some banks needs a JavaScript runtime in order to work. So if you find an error like "Could not find JavaScript runtime" try to install one. It has been tested with nodejs.

## Installation

Installation from RubyGems:

    # BBVA
    gem install bankscrap-bbva

    # ING
    gem install bankscrap-ing

Or, if you're using Bundler, just add the following to your Gemfile:

    # BBVA
    gem 'bankscrap-bbva'

    # ING
    gem 'bankscrap-ing'

Note that you only need to install the gem for your selected bank – the main gem (`bankscrap`) will be installed as a dependency.

## Usage

### From terminal
#### Bank account balance

###### BBVA

    $ bankscrap balance YourBank --user YOUR_BANK_USER --password YOUR_BANK_PASSWORD

###### ING Direct
ING needs one more argument: your birthday.

    $ bankscrap balance ING --user YOUR_DNI --password YOUR_PASSWORD --extra=birthday:01/01/1980

Replace 01/01/1980 with your actual birthday.

#### Transactions for last 30 days
###### BBVA

    $ bankscrap transactions BBVA --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

###### ING Direct

    $ bankscrap transactions ING --user YOUR_DNI --password YOUR_PASSWORD --extra=birthday:01/01/1980

#### Transactions with date range

    $ bankscrap transactions YourBank --user YOUR_BANK_USER --password YOUR_BANK_PASSWORD --from 01-01-2015 --to 01-02-2015

---

By default it will use your first bank account, if you want to fetch transactions for a different account you can use this syntax:

    $ bankscrap transactions YourBank your_iban --user YOUR_DNI --password YOUR_PASSWORD

If you don't want to pass your user and password everytime you can define them in your .bash_profile by adding:

    export BANK_SCRAP_USER=YOUR_BANK_USER
    export BANK_SCRAP_PASSWORD=YOUR_BANK_PASSWORD

#### Export transactions to CSV

    $ bankscrap transactions YourBank --user YOUR_BANK_USER --password YOUR_BANK_PASSWORD --format CSV [--output ./my_transactions.csv]

Currently only CSV is supported. The output parameter is optional, by default `transactions.csv` is used.

### From Ruby code

You can also use this gem from your own app as library. To do so first you must initialize a BankScrap::Bank object


```ruby
# BBVA
require 'bankscrap-bbva'
bbva = Bankscrap::BBVA::Bank.new(YOUR_BBVA_USER, YOUR_BBVA_PASSWORD)

# ING
require 'bankscrap-ing'
ing = Bankscrap::ING::Bank.new(YOUR_DNI, YOUR_ING_PASSWORD, extra_args: {"birthday" => "dd/mm/yyyy"})
```


The initialize method will automatically login and fetch your bank accounts

You can now explore your bank accounts accounts:

```ruby
bank.accounts
```

And get its balance:
```ruby
bank.accounts.first.balance
```

Get last month transactions for a particular account:

```ruby
account = bank.accounts.first
account.transactions
```

Get transactions for last year (from now):

```ruby
account = bank.accounts.first
account.transactions = account.fetch_transactions(start_date: Date.today - 1.year, end_date: Date.today)
account.transactions
```



## Contributing

1. Fork it ( https://github.com/bank-scrap/bank_scrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Thanks to Javier Cuevas (@javiercr) for his [BBVA](https://github.com/javiercr/bbva) gem.
