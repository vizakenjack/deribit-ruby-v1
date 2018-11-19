require 'websocket-client-simple'

module Deribit
  class WS

    URL = ENV['WS_DOMAIN'] || 'wss://www.deribit.com/ws/api/v1/'
    AVAILABLE_EVENTS = [:order_book, :trade, :user_order]

    attr_reader :socket, :response, :ids_stack, :handler

    def initialize(api_key, api_secret, handler = Handler)
      @credentials = Credentials.new(api_key, api_secret)
      @request     = Request.new(@credentials)
      @socket      = connect

      @handler    = handler.new
      @ids_stack  = []
      start_handle
    end

    def connect
      WebSocket::Client::Simple.connect(URL)
    end

    def reconnect!
      @socket = connect
      start_handle
    end

    def ping
      message = {action: "/api/v1/public/ping"}
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
    def subscribe(instruments=[] , events: ["user_order"])
      raise "Events must include only #{AVAILABLE_EVENTS.join(", ")} actions" if events.map{|e| AVAILABLE_EVENTS.include?(e.to_sym)}.index(false) or events.empty?
      raise "instruments are required" if instruments.empty?
      arguments = {instrument: instruments, event: events}
      send(path: '/api/v1/private/subscribe', arguments: arguments)
    end

    def account
      send(path: '/api/v1/private/account')
    end

    def getinstruments(expired: false)
      send(path: '/api/v1/public/getinstruments', arguments: {expired: expired})
    end

    def getcurrencies
      send(path: '/api/v1/public/getcurrencies')
    end

    def handle_notifications(notifications)
      return if notifications.empty?
      notification, *tail = notifications;
      handler.send(notification["message"], notification["result"])
      handle_notifications(tail)
    end

    private

    def start_handle
      instance = self
      @socket.on :message do |msg|
        if msg.type == :text
          json = JSON.parse(msg.data, symbolize_names: true)
          #if find query send json to handler
          if json[:id] and stack_id = instance.ids_stack.find{|i| i[json[:id]]}
            method  = stack_id[json[:id]]
            #pass the method to handler
            instance.ids_stack.delete(stack_id)
            instance.handler.send(method, json)
          elsif json[:notifications]
            instance.handle_notifications(json[:notifications])
          else
            raise "A handle method not found for #{json}!"
          end

        elsif msg.type == :close
          instance.reconnect!
        end
      end

      @socket.on :close do |e|
        p e
        exit 1
      end

      @socket.on :error do |e|
        p e
      end
    end


    def send(path: , arguments: {})
      return unless path
      params = {action: path, arguments: arguments}
      sig = @request.generate_signature(path, arguments)
      params[:sig] = sig
      params[:id] = Time.now.to_i

      action = path[/\/api.*\/([^\/]+)$/, 1]
      put_id(params[:id], action)

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
