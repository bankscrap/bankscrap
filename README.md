# Bankscrap

Ruby gem to extract balance and transactions from banks. You can use it either as command line tool or as a library.

The aim of this project is to build a library which interacts with some of the most used banks. We already know how boring is to look for your balance on the web, so let's do it with the command line.

Feel free to contribute and add your bank if it isn't supported.

## Supported banks
- Bankinter
- BBVA

## Requirements

Some banks needs a JavaScript runtime in order to work. So if you find an error like "Could not find JavasScript runtime" try to install one. It has been tested with nodejs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bank_scrap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bank_scrap

## Usage

Retrieve balance account

    $ bank_scrap balance BANK_NAME --user YOUR_USER --password YOUR_PASSWORD

BANK_NAME should be in underscore case (`bankinter`, `bbva`).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bankscrap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Thanks

Thanks to Javier Cuevas (@javiercr) for his Bbva gem.
