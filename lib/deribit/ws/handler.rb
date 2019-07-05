module Deribit
  class WS
    
    class Handler
      AVAILABLE_METHODS = [
        :account, 
        :getcurrencies, 
        :subscribe, 
        :unsubscribe, 
        :buy,
        :sell, 
        :trade, 
        :my_trade_event, 
        :order_book_event, 
        :user_order_event, 
        :announcements, 
        :index, 
        :heartbeat, 
        :pong
      ]
      SILENT = [:setheartbeat, :heartbeat, :"public API test"]

      def method_missing(m, *json, &block)
        return false  if SILENT.include?(m.to_sym)
        
        puts "Delegating #{m}"
        if AVAILABLE_METHODS.include?(m.to_sym)
          notice(json)
        else
          super
        end
      end

      def getinstruments(json)
        response = json
        response = json[:result].select {|i| i[:isActive] == true} if json[:result]
        notice(response)
      end

      def notice(json)
        puts "Notice: #{json.inspect}"  unless SILENT.include?(json[:message].to_sym)
      end
    end

  end
end
