module Deribit
  class WS

    class Handler
      AVAILABLE_METHODS = [:account, :getcurrencies, :subscribe, :trade_event, :my_trade_event, :order_book_event, :user_order_event, :announcements, :index]

      def method_missing(m, json, &block)
        puts "Delegating #{m}"
        if AVAILABLE_METHODS.include?(m.to_sym)
          notice(json)
        else
          super
        end
      end

      def getinstruments(json)
        response = json
        response = json["result"].select {|i| i["isActive"] == true} if json["result"]
        p response
      end

      private

      def notice(json)
        puts "WARNING: This is a virtual method, you should create a inheritance class. See readme for reference"
        puts "DEBUG: "
        p json
      end
    end

  end
end
