module Deribit
  class WS
    class Handler
      attr_reader :timestamp
      
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
        return json.each { |e| notice(e) }  if json.is_a?(Array)

        msg = json.is_a?(String) ? json : json[:message]
        puts "Notice: #{msg}"  if msg && !SILENT.include?(msg.to_sym)
      end

      def handle_error(json, error)
        puts "Alert! #{error.class} on message: '#{json.try(:fetch, :message)}', #{json.inspect}. Message: #{error.full_message}"
      end

      def update_timestamp!
        @timestamp = Time.now.to_i
      end
    end

  end
end
