require 'websocket-client-simple'

module Deribit
  class WS

    URL = ENV['WS_DOMAIN'] || 'wss://www.deribit.com/ws/api/v1/'

    attr_reader :socket, :response

    def initialize(api_key, api_secret, handler = Handler)
      credentials = Credentials.new(api_key, api_secret)
      @request    = Request.new(credentials)
      @socket     = WebSocket::Client::Simple.connect(URL)
      @handler    = handler
      start_handle
    end

    def ping
      message = {action: "/api/v1/public/ping"}
      @socket.send(message.to_json)
    end

    def subscribe
      send()
    end

    private

    def start_handle
      @socket.on :message do |msg|
        json = JSON.parse(msg.data)
        puts json
      end
    end

    def send(path)
      {action: "/api/v1/public/ping"}
    end
  end

end
