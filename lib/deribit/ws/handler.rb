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
        :my_trade_event, 
        :order_book_event, 
        :user_order_event, 
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
          if json.is_a?(Array)
            json.each { |j| notice(j) }
          else
            notice(json)
          end
        else
          super
        end
      end

      def notice(json)
        puts "Notice: #{json.inspect}"  unless SILENT.include?(json[:message].to_sym)
      end
    end

  end
end
