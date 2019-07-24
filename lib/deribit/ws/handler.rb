module Deribit
  class WS
    
    class Handler
      AVAILABLE_METHODS = [
        :account, 
        :getcurrencies, 
        :subscribe, 
        :subscribed, 
        :unsubscribe, 
        :buy,
        :sell, 
        :trade, 
        :trade_event, 
        :order_book_event, 
        :user_order_event, 
        :user_orders_event, 
        :announcements, 
        :index, 
        :heartbeat,
        :order,
        :pong
      ]
      SILENT = [:setheartbeat, :subscribed, :heartbeat, :"public API test"]

      def method_missing(m, *json, &block)
        return false  if SILENT.include?(m.to_sym)
        
        puts "Delegating #{m}"
        if AVAILABLE_METHODS.include?(m.to_sym)
          notice(json)
        else
          super
        end
      end

      def notice(json)
        puts "Notice: #{json.inspect}"  if !json[:message] || SILENT.include?(json[:message].to_sym)
      end
    end

  end
end
