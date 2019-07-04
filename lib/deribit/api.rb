module Deribit
  class API
    attr_reader :request

    def initialize(key, secret, test: false)
      @request = Request.new(key, secret, test: test)
    end

    def orderbook(instrument)
      request.send(path: "/api/v1/public/getorderbook", params: {instrument: instrument})
    end

    def instruments(expired: false, only_active: true)
      response = request.send(path: '/api/v1/public/getinstruments', params: {expired: expired})
      if response.is_a?(Array) and only_active
        response = response.select {|i| i[:isActive] == true}
      end

      response
    end

    def index
      request.send(path: '/api/v1/public/index', params: {})
    end

    def test
      request.send(path: '/api/v1/public/test', params: {})
    end

    def currencies
      request.send(path: '/api/v1/public/getcurrencies', params: {})
    end

    def last_trades(instrument, count: nil, since: nil)
      params = {instrument: instrument}
      params[:count] = count if count
      params[:since] = since if since

      request.send(path: '/api/v1/public/getlasttrades', params: params)
    end

    def summary(instrument = 'all')
      params = {}
      params[:instrument] = instrument if instrument

      request.send(path: '/api/v1/public/getsummary', params: params)
    end

    def margins(instrument, quantity: 1, price: 0.01, amount: nil)
      params = {
          instrument: instrument,
          quantity:   quantity,
          amount:     amount,
          price:      price
      }

      request.send(path: '/api/v1/private/getmargins', params: params)
    end

    def account(full: false)
      params = {
        ext: full
      }

      request.send(path: '/api/v1/private/account', params: params)
    end


    #  | Name         | Type       | Decription                                                                        |
    #  |--------------|------------|-----------------------------------------------------------------------------------|
    #  | `instrument` | `string`   | Required, instrument name                                                         |
    #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    #  | `type`       | `string`   | Required, "limit", "market" or for futures only: "stop_limit"                     |
    #  | `stopPx`     | `string`   | Required, needed for stop_limit order, defines stop price                         |
    #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    #  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
    #  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
    #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

    def buy(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, reduce_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity,
          price:      price
      }

      %i(type stopPx post_only reduce_only label max_show adv execInst).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      request.send(path: '/api/v1/private/buy', params: params)
    end


    #  | Name         | Type       | Decription                                                                        |
    #  |--------------|------------|-----------------------------------------------------------------------------------|
    #  | `instrument` | `string`   | Required, instrument name                                                         |
    #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    #  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
    #  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
    #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |
    #

    def sell(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, reduce_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity,
          price:      price
      }

      %i(type stopPx post_only reduce_only label max_show adv execInst).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      request.send(path: '/api/v1/private/sell', params: params)
    end

    #
    #  | Name         | Type       | Decription                                                                        |
    #  |--------------|------------|-----------------------------------------------------------------------------------|
    #  | `order_id`   | `integer`  | Required, ID of the order returned by "sell" or "buy" request                     |
    #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

    def edit(order_id, quantity, price, post_only: nil, adv: nil, stopPx: nil)
      params = {
        orderId:    order_id,
        quantity:   quantity,
        stopPx:     stopPx,
        price:      price
      }

      %i(post_only adv stopPx).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      request.send(path: '/api/v1/private/edit', params: params)
    end

    def cancel(order_id)
      params = {
        "orderId": order_id
      }

      request.send(path: '/api/v1/private/cancel', params: params)
    end

    def cancel_all(type = "all")
      params = {
        "type": type
      }

      request.send(path: '/api/v1/private/cancelall', params: params)
    end

    def open_orders(instrument: nil, order_id: nil, type: nil)
      params = {}
      params[:instrument] = instrument if instrument
      params[:orderId]    = order_id if order_id
      params[:type]       = type if type

      request.send(path: '/api/v1/private/getopenorders', params: params)
    end

    def positions
      request.send(path: '/api/v1/private/positions', params: {})
    end

    def order_state(order_id)
      params = {
        "orderId": order_id
      }

      request.send(path: '/api/v1/private/orderstate', params: params)
    end

    def order_history(count: nil, offset: nil)
      params = {}
      params[:count] = count if count
      params[:offset] = offset if offset

      request.send(path: '/api/v1/private/orderhistory', params: params)
    end

    def trade_history(count: nil, instrument: nil, start_trade_id: nil)
      params = {}

      %i(count instrument).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      params[:startTradeId] = start_trade_id if start_trade_id

      request.send(path: '/api/v1/private/tradehistory', params: params)
    end

  end
end
