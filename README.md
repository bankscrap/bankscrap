# BankScrap

Ruby gem to extract account balance and transactions from banks. You can use it either as command line tool or as a library.

Feel free to contribute and add your bank if it isn't supported.

## Supported banks

|                 |  BBVA  | ING Direct | Bankinter |
|-----------------|:------:|:----------:|:---------:|
| Account Balance |    ✓   |     ✓     |    WIP    |
|  Transactions   |    ✓   |     ✓     |    WIP    |

Interested in any other bank? Open a new Issue and we'll try to help.
 
## Background and motivation

Most banks don't offer public APIs and the only way to access your data (balance and transactions) is through their websites... and most bank websites are a f*cking nightmare.

We are developers and we don't want to waste time doing things we are able to automate. Having to perform 20 clicks in an awful website just to check how much money we have is not something we like.

There are two approaches to solve this problem: 
- Web scraping on the bank's site.
- Reverse engineering the bank's mobile app to use the same API the app uses.

BankScrap uses both methods depending on the bank.

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

##### Bankinter

    $ bank_scrap balance bankinter --user YOUR_BANKINTER_USER --password YOUR_BANKINTER_PASSWORD

##### BBVA

    $ bank_scrap balance bbva --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

##### ING Direct
ING needs one more argument: your bithday.

    $ bank_scrap balance ing --user YOUR_DNI --password YOUR_PASSWORD --extra=birthday:01/01/1980

Replace 01/01/1980 with your actual birthday.

---
If you don't want to pass your user and password everytime you can define them in your .bash_profile by adding:

    export BANK_SCRAP_USER=YOUR_BANK_USER
    export BANK_SCRAP_PASSWORD=YOUR_BANK_PASSWORD

### From Ruby code

You can also use this gem from your own app as library. To do so first you must initialize a BankScrap::Bank object


```ruby
require 'bank_scrap'
# BBVA
bbva = BankScrap::Bbva.new(YOUR_BBVA_USER, YOUR_BBVA_PASSWORD)
# ING
ing = BankScrap::Ing.new(YOUR_DNI, YOUR_ING_PASSWORD, extra_args: {"birthday" => "dd/mm/yyyy"})
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

1. Fork it ( https://github.com/ismaGNU/bank_scrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Thanks to Javier Cuevas (@javiercr) for his Bbva gem.
