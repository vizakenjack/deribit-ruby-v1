# Deribit

# API Client for [Deribit API](https://www.deribit.com/docs/api/)

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


* `sell(instrument, quantity, price, post_only: post_only, label: label, max_show: max_show, adv: adv)` - [Doc](https://www.deribit.com/docs/api/#sell), private

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


* `edit(order_id, quantity, price, post_only: post_only, adv: adv)` - [Doc](https://www.deribit.com/docs/api/#edit)

  Edit price and/or quantity of the own order. (Authorization is required).

  **Parameters**

  | Name         | Type       | Decription                                                                        |
  |--------------|------------|-----------------------------------------------------------------------------------|
  | `order_id`   | `integer`  | Required, ID of the order returned by "sell" or "buy" request                     |
  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

`cancel(order_id)` - [Doc](https://www.deribit.com/docs/api/#cancel), private

  Cancell own order by id.

  **Parameters**

  | Name         | Type       | Decription                                                                        |
  |--------------|------------|-----------------------------------------------------------------------------------|
  | `order_id`    | `integer`  | Required, ID of the order returned by "sell" or "buy" request

* `getopenorders(instrument)` - [Doc](https://www.deribit.com/docs/api/#getopenorders), private

  Retrieve open orders.

  **Parameters**

  | Name         | Type       | Description                                                           |
  |--------------|------------|-----------------------------------------------------------------------|
  | `instrument` | `string`   | Optional, instrument name, use if want orders for specific instrument |

* `positions()` - [Doc](https://www.deribit.com/docs/api/#positions), private

  Retreive positions.

* `orderhistory(count)` - [Doc](https://www.deribit.com/docs/api/#orderhistory), private

  Get history.

  **Parameters**

  | Name       | Type       | Description                                                |
  |------------|------------|------------------------------------------------------------|
  | `count`    | `integer`  | Optional, number of requested records                      |

* `tradehistory(count: count, instrument: instrument, start_trade_id: start_trade_id)` - [Doc](https://www.deribit.com/docs/api/#tradehistory), private

  Get private trade history of the account. (Authorization is required). The result is ordered by trade identifiers (trade id-s).

  **Parameters**

  | Name             | Type       | Description                                                                                        |
  |------------------|------------|----------------------------------------------------------------------------------------------------|
  | `count`          | `integer`  | Optional, number of results to fetch. Default: 20                                                  |
  | `instrument`     | `string`   | Optional, name of instrument, also aliases “all”, “futures”, “options” are allowed. Default: "all" |
  | `start_trade_id` | `integer`  | Optional, number of requested records                                                              |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sunchess/deribit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Deribit project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deribit/blob/master/CODE_OF_CONDUCT.md).
