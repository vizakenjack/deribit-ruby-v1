# Deribit

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/deribit`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deribit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deribit

## Usage


### Example

```
require 'deribit'

api = Deribit::API.new("KEY", "SECRET")

api.index
api.account
```

ENV['DOMAIN'] is changing the default domain https://deribit.com/

```
DOMAIN=https://test.deribit.com/ bin/console
```

## API

`Deribit::API.new(key, secret)`

Constructor creates new API client.

**Parameters**

| Name     | Type     | Decription                                                |
|----------|----------|-----------------------------------------------------------|
| `key`    | `string` | Optional, Access Key needed to access Private functions   |
| `secret` | `string` | Optional, Access Secret needed to access Private functions|


### Methods

* `getinstruments()` - [Doc](https://www.deribit.com/docs/api/#getinstruments), public

  Returns active instruments

* `getorderbook(instrument)` - [Doc](https://www.deribit.com/docs/api/#getinstruments), public

  Retrieve the orderbook for a given instrument.

  **Parameters**

  | Name         | Type       | Decription                                                 |
  |--------------|------------|------------------------------------------------------------|
  | `instrument` | `string`   | Required, instrument name                                  |


* `index()` - [Doc](https://www.deribit.com/docs/api/#index), public

  Get price index, BTC-USD rates.

* `getcurrencies()` - [Doc](https://www.deribit.com/docs/api/#getcurrencies), public

  Get all supported currencies.

* `getlasttrades(instrument, count: count, since: since)` - [Doc](https://www.deribit.com/docs/api/#getlasttrades), public

  Retrieve the latest trades that have occured for a specific instrument.

  **Parameters**

  | Name         | Type       | Decription                                                                    |
  |--------------|------------|-------------------------------------------------------------------------------|
  | `instrument` | `string`   | Required, instrument name                                                     |
  | `count`      | `integer`  | Optional, count of trades returned (limitation: max. count is 100)            |
  | `since`      | `integer`  | Optional, “since” trade id, the server returns trades newer than that “since” |


* `getsummary(instrument)` - [Doc](https://www.deribit.com/docs/api/#getsummary), public

  Retrieve the summary info such as Open Interest, 24H Volume etc for a specific instrument.

  **Parameters**

  | Name         | Type       | Decription                                                 |
  |--------------|------------|------------------------------------------------------------|
  | `instrument` | `string`   | Required, instrument name                                  |


* `account()` - [Doc](https://www.deribit.com/docs/api/#account), Private

  Get user account summary.

* `buy(instrument, quantity, price, type: "limit", stopPx: stopPx, post_only: post_only, label: label, max_show: max_show, adv: adv)` - [Doc](https://www.deribit.com/docs/api/#buy), private

  Place a buy order in an instrument.

  **Parameters**

  | Name         | Type       | Decription                                                                        |
  |--------------|------------|-----------------------------------------------------------------------------------|
  | `instrument` | `string`   | Required, instrument name                                                         |
  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
  | `type`       | `string`   | Required, "limit", "market" or for futures only: "stop_limit"                     |
  | `stopPx`     | `string`   | Required, needed for stop_limit order, defines stop price                         |
  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |


* `sell(instrument, quantity, price, postOnly, label)` - [Doc](https://www.deribit.com/docs/api/#sell), private

  Place a sell order in an instrument.

  **Parameters**

  | Name         | Type       | Decription                                                                        |
  |--------------|------------|-----------------------------------------------------------------------------------|
  | `instrument` | `string`   | Required, instrument name                                                         |
  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sunchess/deribit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Deribit project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deribit/blob/master/CODE_OF_CONDUCT.md).
