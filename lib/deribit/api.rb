module Deribit
  class API
    attr_reader :request

    def initialize(api_key, api_secret)
      credentials = Credentials.new(api_key, api_secret)
      @request    = Request.new(credentials)
    end

    def getorderbook(instrument)
      request.send(path: "/api/v1/public/getorderbook", params: {instrument: instrument})
    end

    def getinstruments(expired: false, only_active: true)
      response = request.send(path: '/api/v1/public/getinstruments', params: {expired: expired})
      if response.is_a?(Array) and only_active
       response = response.select {|i| i[:isActive] == true}
      end

      response
    end

    def index
      request.send(path: '/api/v1/public/index', params: {})
    end

    def getcurrencies
      request.send(path: '/api/v1/public/getcurrencies', params: {})
    end

    def getlasttrades(instrument, count: nil, since: nil)
      params = {instrument: instrument}
      params[:count] = count if count
      params[:since] = since if since

      request.send(path: '/api/v1/public/getlasttrades', params: params)
    end

    def getsummary(instrument)
      request.send(path: '/api/v1/public/getsummary', params: {instrument: instrument})
    end

    def account(params={})
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

    def buy(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity,
          price:      price
      }

      %i(type stopPx post_only label max_show adv execInst).each do |var|
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

    def sell(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity,
          price:      price
      }

      %i(type stopPx post_only label max_show adv execInst).each do |var|
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

    def cancelall(type = "all")
      params = {
        "type": type
      }

      request.send(path: '/api/v1/private/cancelall', params: params)
    end

    def getopenorders(instrument: nil, order_id: nil, type: nil)
      params = {}
      params[:instrument] = instrument if instrument
      params[:orderId]    = order_id if order_id
      params[:type]       = type if type

      request.send(path: '/api/v1/private/getopenorders', params: params)
    end

    def positions
      request.send(path: '/api/v1/private/positions', params: {})
    end

    def orderstate(order_id)
      params = {
        "orderId": order_id
      }

      request.send(path: '/api/v1/private/orderstate', params: params)
    end

    def orderhistory(count=nil)
      params = {}
      params[:count] = count if count

      request.send(path: '/api/v1/private/orderhistory', params: params)
    end

    def tradehistory(count: nil, instrument: nil, start_trade_id: nil)
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
