# 💸 Bankscrap 💸

[![](http://188.166.39.57:3000/badge.svg)](http://188.166.39.57:3000)
[![Gem Version](https://badge.fury.io/rb/bankscrap.svg)](https://badge.fury.io/rb/bankscrap)
[![Build Status](https://travis-ci.org/bankscrap/bankscrap.svg?branch=master)](https://travis-ci.org/bankscrap/bankscrap)

Ruby gem to extract account balance and transactions from banks. You can use it either as command line tool or as a library.

Feel free to contribute and add your bank if it isn't supported.

## Supported banks

* **BBVA** (personal accounts): [bankscrap-bbva](https://github.com/bankscrap/bankscrap-bbva)
* **BBVA Net Cash** (business accounts): [bankscrap-bbva-net-cash](https://github.com/bankscrap/bankscrap-bbva-net-cash)
* **ING Direct**: [bankscrap-ing](https://github.com/bankscrap/bankscrap-ing)
* **Arquia Banca**: [bankscrap-arquia](https://github.com/bankscrap/bankscrap-arquia)
* **Banc Sabadell** (WIP): [bankscrap-banc-sabadell](https://github.com/bankscrap/bankscrap-banc-sabadell)
* **Santander** (WIP): [bankscrap-santander](https://github.com/bankscrap/bankscrap-santander)
* **Openbank** (WIP): [bankscrap-openbank](https://github.com/bankscrap/bankscrap-openbank)

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

    $ bankscrap balance BBVA --credentials=user:YOUR_BANK_USER password:YOUR_BANK_PASSWORD

###### ING Direct
ING needs one more argument: your birthday.

    $ bankscrap balance ING --credentials=user:YOUR_DNI password:YOUR_BANK_PASSWORD birthday:01/01/1980

Replace 01/01/1980 with your actual birthday.

#### Transactions for last 30 days
###### BBVA

    $ bankscrap transactions BBVA --credentials=user:YOUR_BANK_USER password:YOUR_BANK_PASSWORD

###### ING Direct

    $ bankscrap transactions ING --credentials=dni:YOUR_DNI password:YOUR_BANK_PASSWORD birthday:01/01/1980

#### Transactions with date range

    $ bankscrap transactions YourBank --credentials=user:YOUR_BANK_USER password:YOUR_BANK_PASSWORD --from 01-01-2015 --to 01-02-2015

---

By default it will use your first bank account, if you want to fetch transactions for a different account you can use this syntax:

    $ bankscrap transactions YourBank --iban "your_iban" --credentials=user:YOUR_BANK_USER password:YOUR_BANK_PASSWORD

If you don't want to pass your user and password everytime you can define them in your .bash_profile by adding:

    export BANKSCRAP_[BANK_NAME]_USER=YOUR_BANK_USER
    export BANKSCRAP_[BANK_NAME]_PASSWORD=YOUR_BANK_USER
    export BANKSCRAP_[BANK_NAME]_ANY_OTHER_CREDENTIAL=ANY_OTHER_CREDENTIAL

eg:
    export BANKSCRAP_BBVA_NET_CASH_USER=YOUR_BANK_USER


#### Export transactions to CSV

    $ bankscrap transactions YourBank --credentials=user:YOUR_BANK_USER password:YOUR_BANK_PASSWORD --format CSV [--output ./my_transactions.csv]

Currently only CSV is supported. The output parameter is optional, by default `transactions.csv` is used.

### From Ruby code

You can also use this gem from your own app as library. To do so first you must initialize a BankScrap::Bank object


```ruby
# BBVA
require 'bankscrap-bbva'
bbva = Bankscrap::BBVA::Bank.new(user: YOUR_BBVA_USER, password: YOUR_BBVA_PASSWORD)

# ING
require 'bankscrap-ing'
ing = Bankscrap::ING::Bank.new(dni: YOUR_DNI, password: YOUR_ING_PASSWORD, birthday: "dd/mm/yyyy")
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

### From Ruby code (with IRB, useful when developing)

In the terminal:

```
irb -I lib/ -r 'bankscrap'
```

After that, you can use your bank adapter as usual:

```ruby
require 'bankscrap-ing'
ing = Bankscrap::ING::Bank.new(dni: YOUR_DNI, password: YOUR_ING_PASSWORD, birthday: "dd/mm/yyyy")
```

## Contributing

1. Fork it ( https://github.com/bankscrap/bankscrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Thanks to Javier Cuevas (@javiercr) for his [BBVA](https://github.com/javiercr/bbva) gem.
