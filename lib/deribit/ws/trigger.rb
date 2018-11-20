
module Deribit
  class WS
    class Trigger < Handler

      def initialize(price: , instrument: "BTC-PERPETUAL", direction: :more, block: ->{puts "DEBUG: Triggered block executed"})
        @insrument, @price, @direction = instrument, price, direction
        @block = block
      end

      def trade_event(json)
        max_price, min_price = get_min_max_price(json)

        if @direction == :more
          @block.call if @price >= max_price
        else
          @block.call if @price <= min_price
        end
      end

      #[{:quantity=>42, :amount=>420.0, :tradeId=>2359783, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743547, :price=>4354.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450613, :tickDirection=>3, :indexPrice=>4362.65, :state=>"open", :label=>"", :me=>""},
      #{:quantity=>79, :amount=>790.0, :tradeId=>2359784, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743562, :price=>4355.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450614, :tickDirection=>0, :indexPrice=>4362.65, :state=>"closed", :label=>"", :me=>""},
      #{:quantity=>21, :amount=>210.0, :tradeId=>2359785, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743572, :price=>4355.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450615, :tickDirection=>1, :indexPrice=>4362.65, :state=>"open", :label=>"", :me=>""},
      #{:quantity=>100, :amount=>1000.0, :tradeId=>2359786, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743572, :price=>4356.0, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450616, :tickDirection=>0, :indexPrice=>4362.65, :state=>"open", :label=>"", :me=>""},
      #{:quantity=>100, :amount=>1000.0, :tradeId=>2359787, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743572, :price=>4356.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450617, :tickDirection=>0, :indexPrice=>4362.65, :state=>"open", :label=>"", :me=>""}]
      def get_min_max_price(json)
        prices = json.map{|i| i[:price]}
        [prices.max, prices.min]
      end

    end
  end
end
