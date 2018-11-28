require_relative 'support/test_handler'
require_relative 'support/test_trigger'

RSpec.describe Deribit::WS do
  let(:key){"BxxwbXRLmYid"}
  let(:secret){"AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO"}


  describe "init" do
    let(:handler){TestHandler}
    it "when handler is a class" do
      ws = Deribit::WS.new(key, secret, handler)
      expect(ws.handler.instance_of?(Class)).to be_falsy
    end

    it "when handler is an instance" do
      ws = Deribit::WS.new(key, secret, handler.new)
      expect(ws.handler.instance_of?(TestHandler)).to be_truthy
    end

    it "socket is present" do
      ws = Deribit::WS.new(key, secret)
      expect(ws.socket.url).to eq('wss://test.deribit.com/ws/api/v1/')
    end
  end

  describe "#add_subscribed_instruments" do
    let(:ws){Deribit::WS.new(key, secret)}

    it "when add new instrument as string " do
      ws.add_subscribed_instruments(instruments: "BTC-29MAR19-2500-C" , events: ["trade"])
      expect(ws.subscribed_instruments[:trade]).to eq(["BTC-29MAR19-2500-C"])
    end

    it "when add new instrument as array" do
      ws.add_subscribed_instruments(instruments: ["BTC-29MAR19-2500-C"] , events: ["trade"])
      expect(ws.subscribed_instruments[:trade]).to eq(["BTC-29MAR19-2500-C"])
    end
  end

  describe "#handle_notifications" do
    before do
      @result = 0
    end

    let(:ws){Deribit::WS.new(key, secret)}
    let(:trigger){TestTrigger.new(price: 4500, block: ->(){@result = 1})}
    let(:trigger2){TestTrigger.new(price: 3500, direction: :less, block: ->(){@result = 1})}
    let(:notification){
      {
        success: true,
        message: "trade_event",
        result: [{:quantity=>42, :amount=>420.0, :tradeId=>2359783, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743547, :price=>4354.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450613, :tickDirection=>3, :indexPrice=>4362.65, :state=>"open", :label=>"", :me=>""},
        {:quantity=>79, :amount=>790.0, :tradeId=>2359784, :instrument=>"BTC-PERPETUAL", :timeStamp=>1542715743562, :price=>4355.5, :direction=>"buy", :orderId=>0, :matchingId=>0, :tradeSeq=>450614, :tickDirection=>0, :indexPrice=>4362.65, :state=>"closed", :label=>"", :me=>""}]
      }
    }

    it "when trigger direction is more" do
      ws.set_trigger(trigger)
      ws.handle_notifications(notification)
      expect(@result).to eq(1)
    end

    it "when trigger direction is less" do
      ws.set_trigger(trigger2)
      ws.handle_notifications(notification)
      expect(@result).to eq(1)
    end
  end
end
