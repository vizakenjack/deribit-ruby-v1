require 'websocket-client-simple'

module Deribit
  class WS

    URL = ENV['WS_DOMAIN'] || 'wss://www.deribit.com/ws/api/v1/'
    AVAILABLE_EVENTS = [:order_book, :trade, :user_order]

    attr_reader :socket, :response

    def initialize(api_key, api_secret, handler = Handler)
      @credentials = Credentials.new(api_key, api_secret)
      @request    = Request.new(credentials)
      @socket     = WebSocket::Client::Simple.connect(URL)
      @handler    = handler
      start_handle
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

    def account()
    end

    private

    def start_handle
      @socket.on :message do |msg|
        json = JSON.parse(msg.data)
        puts json
      end

      @socket.on :error do |e|
        p e
      end
    end

    def send(path: , arguments: {})
      return unless path or arguments
      params = {action: path, arguments: arguments}
      sig = @request.generate_signature(path, arguments)
      p sig
      params[:sig] = sig
      params[:id]  = Time.now.to_i
      @socket.send(params.to_json)
    end
  end

end
