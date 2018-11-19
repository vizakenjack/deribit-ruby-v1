require 'websocket-client-simple'

module Deribit
  class WS

    URL = ENV['WS_DOMAIN'] || 'wss://www.deribit.com/ws/api/v1/'
    AVAILABLE_EVENTS = [:order_book, :trade, :user_order]

    attr_reader :socket, :response, :ids_stack

    def initialize(api_key, api_secret, handler = Handler)
      @credentials = Credentials.new(api_key, api_secret)
      @request     = Request.new(@credentials)
      @socket      = connect

      @handler    = handler
      @ids_stack  = []
      start_handle
    end

    def connect
      WebSocket::Client::Simple.connect(URL)
    end

    def ping
      message = {action: "/api/v1/public/ping"}
      @socket.send(message.to_json)
    end

    def subscribe(instruments: [] , events: [])
      raise "Events must include only #{AVAILABLE_EVENTS.join(", ")} actions" if events.map{|e| AVAILABLE_EVENTS.include?(e)}.index(false) or events.empty?
      raise "instruments are required" if instruments.empty?

      params[:events]    = events
      params[:arguments] = arguments
      send(path: '/api/v1/private/subscribe', arguments: params)
    end

    def account
      send(path: '/api/v1/private/account')
    end

    def getinstruments(expired: false)
      send(path: '/api/v1/public/getinstruments', arguments: {expired: expired})
    end

    private

    def start_handle
      @socket.on :message do |msg|
        p msg
        if msg.type == :text

          json = JSON.parse(msg.data)
          puts json
        elsif msg.type == :close
          reconnect!
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

    def reconnect!
      @socket = connect
      start_handle
    end

    def send(path: , arguments: {})
      return unless path
      #reconnect if need_reconnect?

      params = {action: path, arguments: arguments}
      sig = @request.generate_signature(path, arguments)
      p sig
      params[:sig] = sig
      params[:id], id = Time.now.to_i

      action = path[/\/api.*\/([^\/]+)$/, 1]
      put_id(id, action)

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
