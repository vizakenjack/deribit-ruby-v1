require 'websocket-client-simple'

module Deribit
  class WS
    AVAILABLE_EVENTS = [:order_book, :trade, :my_trade, :user_order, :index, :portfolio, :announcement]

    attr_reader :socket, :response, :ids_stack, :handler, :subscribed_instruments

    def initialize(key, secret, handler: Handler, test_server: nil)
      test_server  = ENV["DERIBIT_TEST_SERVER"]  if test_server == nil
      @request     = Request.new(key, secret, test_server: test_server)
      @socket      = connect(test_server ? WS_TEST_URL : WS_SERVER_URL)
      @handler     = handler.instance_of?(Class) ? handler.new : handler
      @ids_stack  = []

      # the structure of subscribed_instruments: {'event_name' => ['instrument1', 'instrument2']]}
      @subscribed_instruments = {}

      start_handle
    end

    def add_subscribed_instruments(instruments: , events: )
      instruments = [instruments] unless instruments.is_a?(Array)

      events.each do |event|
        _event = event.to_sym
        @subscribed_instruments[_event] = if sub_instr = @subscribed_instruments[_event]
                                            (sub_instr + instruments).uniq
                                          else
                                            instruments.uniq
                                          end
      end
    end

    def connect(url)
      puts "Connecting to #{url}"
      WebSocket::Client::Simple.connect(url)
    end

    def reconnect!
      @socket = connect
      start_handle
      sleep 3
      resubscribe!
    end

    def resubscribe!
      if subscribed_instruments.any?
        subscribed_instruments.each do |event, instruments|
          p "Reconnecting to event: #{event} at instrument: #{instruments}"
          subscribe(instruments, events: event.to_s)
        end
      end
    end

    def close
      @socket.close
    end

    def ping
      message = {action: "/api/v1/public/ping"}
      @socket.send(message.to_json)
    end

    def test
      message = {action: "/api/v1/public/test"}
      @socket.send(message.to_json)
    end

    # events to be reported, possible events:
    # "order_book" -- order book change
    # "trade" -- trade notification
    # "announcements" -- announcements (list of new announcements titles is send)
    # "user_order" -- change of user orders (openning, cancelling, filling)
    # "my_trade" -- filtered trade notification, only trades of the
    # subscribed user are reported with trade direction "buy"/"sell" from the
    # subscribed user point of view ("I sell ...", "I buy ..."), see below.
    # Note, for "index" - events are ignored and can be []
    def subscribe(instruments = ['BTC-PERPETUAL'] , events: ["user_order"], arguments: {})
      instruments = [instruments]  unless instruments.is_a?(Array)
      events = [events]  unless events.is_a?(Array)

      raise "Events must include only #{AVAILABLE_EVENTS.join(", ")} actions" if events.map{|e| AVAILABLE_EVENTS.include?(e.to_sym)}.index(false) or events.empty?
      raise "instruments are required" if instruments.empty?

      arguments = arguments.merge(instrument: instruments, event: events)
      send(path: '/api/v1/private/subscribe', arguments: arguments)
    end

    #unsubscribe for all notifications if instruments is empty
    def unsubscribe(instruments=[])
      instruments = [instruments] unless instruments.is_a?(Array)
      send(path: '/api/v1/private/unsubscribe')
      sleep(0.2)
      if instruments.any?
        @subscribed_instruments.each do |event, _instruments|
          @subscribed_instruments[event] = _instruments - instruments
          subscribe(@subscribed_instruments[event], events: [event])
          sleep(0.2)
        end
      end
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

    def buy(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "mark_price", post_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity
      }
      params[:price] = price if price

      %i(type stopPx post_only label max_show adv execInst).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      send(path: '/api/v1/private/buy', arguments: params)
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

    def sell(instrument, quantity, price, type: "limit", stopPx: nil, execInst: "mark_price", post_only: nil, label: nil, max_show: nil, adv: nil)
      params = {
          instrument: instrument,
          quantity:   quantity
      }
      params[:price] = price if price

      %i(type stopPx post_only label max_show adv execInst).each do |var|
        variable = eval(var.to_s)
        params[var] = variable if variable
      end

      send(path: '/api/v1/private/sell', arguments: params)
    end

    def account
      send(path: '/api/v1/private/account')
    end

    def instruments(expired: false)
      send(path: '/api/v1/public/getinstruments', arguments: {expired: expired})
    end

    def currencies
      send(path: '/api/v1/public/getcurrencies')
    end

    def summary(instrument = 'BTC-PERPETUAL')
      send(path: '/api/v1/public/getsummary', arguments: { instrument: instrument })
    end

    def openorders(instrument: "BTC-PERPETUAL", order_id: nil, type: nil)
      params = {}
      params[:instrument] = instrument if instrument
      params[:orderId]    = order_id if order_id
      params[:type]       = type if type

      send(path: '/api/v1/private/getopenorders', arguments: params)
    end

    def cancel(order_id)
      params = {
        "orderId": order_id
      }

      send(path: '/api/v1/private/cancel', arguments: params)
    end

    def cancel_all(type = "all")
      params = {
        "type": type
      }

      send(path: '/api/v1/private/cancelall', arguments: params)
    end

    def set_heartbeat(interval = "60")
      params = {
        "interval": interval
      }

      send(path: '/api/v1/public/setheartbeat', arguments: params)
    end

    def handle_notifications(notifications)
      return if notifications.empty?
      notification, *tail = notifications
      handler.send(notification[:message], notification[:result])

      handle_notifications(tail)
    end

    private

    def start_handle
      instance = self
      @socket.on :message do |msg|
        # puts "msg = #{msg.inspect}"
        begin
          if msg.type == :text
            json = JSON.parse(msg.data, symbolize_names: true)
            puts "Subscribed!" if json[:message] == "subscribed"

            if json[:message] == "test_request"
              # puts "Got test request: #{json.inspect}" # DEBUG
              instance.test
            elsif json[:id] and stack_id = instance.ids_stack.find{|i| i[json[:id]]}
              method  = stack_id[json[:id]][0]
              #pass the method to handler
              params = instance.ids_stack.delete(stack_id)

              #save subscribed_instruments for resubscribe in unsubscribe action
              if method == 'subscribe'
                params = params[json[:id]][1][:arguments]
                instance.add_subscribed_instruments(instruments: params[:instrument], events: params[:event])
              end

              instance.handler.send(method, json)
            elsif json[:notifications]
              instance.handle_notifications(json[:notifications])
            else
              instance.handler.send(:notice, json)
            end

            instance.handler.update_timestamp!
          elsif msg.type == :close
            puts "trying to reconnect = got close event, msg: #{msg.inspect}"
            instance.reconnect!
          end
        rescue StandardError => e 
          instance.handler.handle_error(json, e)
        end
      end

      @socket.on :error do |e|
        puts e
      end
    end

    def send(path: , arguments: {})
      return unless path
      params = {action: path, arguments: arguments}
      sig = @request.generate_signature(path, arguments)
      params[:sig] = sig
      params[:id] = Time.now.to_i

      action = path[/\/api.*\/([^\/]+)$/, 1]
      put_id(params[:id], [action, params])

      p params
      @socket.send(params.to_json)
    end


    def put_id(id, action)
      @ids_stack << {id => action}
    end

    def pop_id(id)
      @ids_stack.delete(id)
    end
  end

end
