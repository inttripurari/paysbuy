# Paysbuy

Simple API to [Paysbuy](https://www.paysbuy.com/)

## Installation

Add this line to your application's Gemfile:

    gem 'paysbuy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paysbuy

## Usage

    paysbuy = Paysbuy.new(psb_id: "0111111111, biz: "user@paysbuy.com", secure_code: "your secret code")
    result = paysbuy.check_status(payment_id)

Result contains :status and :amount

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
