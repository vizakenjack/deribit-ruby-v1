require 'base64'
require 'net/http'
require 'uri'

module Deribit
  class API
    attr_accessor :key, :secret, :base_uri

    def initialize(key, secret, test: false)
      @key = key
      @secret = secret
      @base_uri = test ? TEST_URL : SERVER_URL
    end

    def method_missing(m, **args, &block)
      if method = Deribit::REST_METHODS[m&.to_sym]
        if args.any?
        end
        binding.pry()
        send m, method[:prefix], params: args
      else
        raise StandardError.new("Method missing: #{m}")
      end
    end

    def send(method_name, prefix, params: {})
      uri = URI(base_uri + API_PATH + prefix + '/' + method_name.to_s)

      if prefix == 'public'
        uri.query = URI.encode_www_form(params)
        response = Net::HTTP.get_response(uri)
      else
        request = Net::HTTP::Post.new(uri.path)
        request.body = URI.encode_www_form(params)
        request.add_field 'x-deribit-sig', generate_signature(uri.path, params)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      if is_error_response?(response)
        json = JSON.parse(response.body)  rescue nil
        message = json['error']  if json
        raise Error.new(code: response.code, message: message)
      else
        process(response)
      end
    end

    def process(response)
      json = JSON.parse(response.body, symbolize_names: true)

      raise Error.new(message: "Failed for #{key}: " + json[:message])  unless json[:success]

      if json.include?(:result)
        json[:result]
      elsif json.include?(:message)
        json[:message]
      else
        "ok"
      end
    end

    def generate_signature(path, params = {})
      timestamp = Time.now.utc.to_i + 1000

      signature_data = {
        _:       timestamp,
        _ackey:  key,
        _acsec:  secret,
        _action: path
       }

      signature_data.update(params)
      sorted_signature_data = signature_data.sort

      converter = ->(data){
        key = data[0]
        value = data[1]
        if value.is_a?(Array)
          [key.to_s, value.join].join('=')
        else
          [key.to_s, value.to_s].join('=')
        end
      }

      items = sorted_signature_data.map(&converter)
      signature_string = items.join('&')

      sha256 = OpenSSL::Digest::SHA256.new
      sha256_signature = sha256.digest(signature_string.encode('utf-8'))

      base64_signature = Base64.encode64(sha256_signature).encode('utf-8')

      [key, timestamp, base64_signature].join('.').strip
    end

    def is_error_response?(response)
      code = response.code.to_i
      code == 0 || code >= 400
    end

    # def orderbook(instrument)
    #   request.send(path: "/api/v1/public/getorderbook", params: {instrument: instrument})
    # end

    # def instruments(expired: false, only_active: true)
    #   response = request.send(path: '/api/v1/public/getinstruments', params: {expired: expired})
    #   if response.is_a?(Array) and only_active
    #     response = response.select {|i| i[:isActive] == true}
    #   end

    #   response
    # end

    # def index
    #   request.send(path: '/api/v1/public/index', params: {})
    # end

    # def test
    #   request.send(path: '/api/v1/public/test', params: {})
    # end

    # def currencies
    #   request.send(path: '/api/v1/public/getcurrencies', params: {})
    # end

    # def last_trades(instrument, count: nil, since: nil)
    #   params = {instrument: instrument}
    #   params[:count] = count if count
    #   params[:since] = since if since

    #   request.send(path: '/api/v1/public/getlasttrades', params: params)
    # end

    # def summary(instrument = 'all')
    #   params = {}
    #   params[:instrument] = instrument if instrument

    #   request.send(path: '/api/v1/public/getsummary', params: params)
    # end

    # def margins(instrument, quantity: 1, price: 0.01, amount: nil)
    #   params = {
    #       instrument: instrument,
    #       quantity:   quantity,
    #       amount:     amount,
    #       price:      price
    #   }

    #   request.send(path: '/api/v1/private/getmargins', params: params)
    # end

    # def account(full: false)
    #   params = {
    #     ext: full
    #   }

    #   request.send(path: '/api/v1/private/account', params: params)
    # end


    # #  | Name         | Type       | Decription                                                                        |
    # #  |--------------|------------|-----------------------------------------------------------------------------------|
    # #  | `instrument` | `string`   | Required, instrument name                                                         |
    # #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    # #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    # #  | `type`       | `string`   | Required, "limit", "market" or for futures only: "stop_limit"                     |
    # #  | `stopPx`     | `string`   | Required, needed for stop_limit order, defines stop price                         |
    # #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    # #  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
    # #  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
    # #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

    # def buy(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, reduce_only: nil, label: nil, max_show: nil, adv: nil)
    #   params = {
    #       instrument: instrument,
    #       quantity:   quantity,
    #       price:      price
    #   }

    #   %i(type stopPx post_only reduce_only label max_show adv execInst).each do |var|
    #     variable = eval(var.to_s)
    #     params[var] = variable if variable
    #   end

    #   request.send(path: '/api/v1/private/buy', params: params)
    # end


    # #  | Name         | Type       | Decription                                                                        |
    # #  |--------------|------------|-----------------------------------------------------------------------------------|
    # #  | `instrument` | `string`   | Required, instrument name                                                         |
    # #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    # #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    # #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    # #  | `label`      | `string`   | Optional, user defined maximum 32-char label for the order                        |
    # #  | `max_show`   | `string`   | Optional, optional parameter, if "0" then the order will be hidden                |
    # #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |
    # #

    # def sell(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "index_price", post_only: nil, reduce_only: nil, label: nil, max_show: nil, adv: nil)
    #   params = {
    #       instrument: instrument,
    #       quantity:   quantity,
    #       price:      price
    #   }

    #   %i(type stopPx post_only reduce_only label max_show adv execInst).each do |var|
    #     variable = eval(var.to_s)
    #     params[var] = variable if variable
    #   end

    #   request.send(path: '/api/v1/private/sell', params: params)
    # end

    # #
    # #  | Name         | Type       | Decription                                                                        |
    # #  |--------------|------------|-----------------------------------------------------------------------------------|
    # #  | `order_id`   | `integer`  | Required, ID of the order returned by "sell" or "buy" request                     |
    # #  | `quantity`   | `integer`  | Required, quantity, in contracts ($10 per contract for futures, ฿1 — for options) |
    # #  | `price`      | `float`    | Required, USD for futures, BTC for options                                        |
    # #  | `post_only`  | `boolean`  | Optional, if true then the order will be POST ONLY                                |
    # #  | `adv`        | `string`   | Optional, can be "implv", "usd", or absent (advanced order type)                  |

    # def edit(order_id, quantity, price, post_only: nil, adv: nil, stopPx: nil)
    #   params = {
    #     orderId:    order_id,
    #     quantity:   quantity,
    #     stopPx:     stopPx,
    #     price:      price
    #   }

    #   %i(post_only adv stopPx).each do |var|
    #     variable = eval(var.to_s)
    #     params[var] = variable if variable
    #   end

    #   request.send(path: '/api/v1/private/edit', params: params)
    # end

    # def cancel(order_id)
    #   params = {
    #     "orderId": order_id
    #   }

    #   request.send(path: '/api/v1/private/cancel', params: params)
    # end

    # def cancel_all(type = "all")
    #   params = {
    #     "type": type
    #   }

    #   request.send(path: '/api/v1/private/cancelall', params: params)
    # end

    # def open_orders(instrument: nil, order_id: nil, type: nil)
    #   params = {}
    #   params[:instrument] = instrument if instrument
    #   params[:orderId]    = order_id if order_id
    #   params[:type]       = type if type

    #   request.send(path: '/api/v1/private/getopenorders', params: params)
    # end

    # def positions
    #   request.send(path: '/api/v1/private/positions', params: {})
    # end

    # def order_state(order_id)
    #   params = {
    #     "orderId": order_id
    #   }

    #   request.send(path: '/api/v1/private/orderstate', params: params)
    # end

    # def order_history(count: nil, offset: nil)
    #   params = {}
    #   params[:count] = count if count
    #   params[:offset] = offset if offset

    #   request.send(path: '/api/v1/private/orderhistory', params: params)
    # end

    # def trade_history(count: nil, instrument: nil, start_trade_id: nil)
    #   params = {}

    #   %i(count instrument).each do |var|
    #     variable = eval(var.to_s)
    #     params[var] = variable if variable
    #   end

    #   params[:startTradeId] = start_trade_id if start_trade_id

    #   request.send(path: '/api/v1/private/tradehistory', params: params)
    # end

  end
end
