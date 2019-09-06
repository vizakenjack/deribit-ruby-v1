require_relative "support/test_handler"

RSpec.describe Deribit::WS do
  let(:key) { "BxxwbXRLmYid" }
  let(:secret) { "AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO" }

  describe "init" do
    let(:handler) { TestHandler }

    it "when handler is a class" do
      ws = Deribit::WS.new(key, secret, handler: handler, test_server: true)
      expect(ws.handler.instance_of?(Class)).to be_falsy
    end

    it "when handler is an instance" do
      ws = Deribit::WS.new(key, secret, handler: handler.new, test_server: true)
      expect(ws.handler.instance_of?(TestHandler)).to be_truthy
    end

    it "socket is present" do
      ws = Deribit::WS.new(key, secret, test_server: true)
      expect(ws.socket.url).to eq("wss://test.deribit.com/ws/api/v1/")
    end
  end

  describe "#add_subscribed_instruments" do
    let(:ws) { Deribit::WS.new(key, secret, test_server: true) }

    it "when add new instrument as string " do
      ws.add_subscribed_instruments(instruments: "BTC-29MAR19-2500-C", events: ["trade"])
      expect(ws.subscribed_instruments[:trade]).to eq(["BTC-29MAR19-2500-C"])
    end

    it "when add new instrument as array" do
      ws.add_subscribed_instruments(instruments: ["BTC-29MAR19-2500-C"], events: ["trade"])
      expect(ws.subscribed_instruments[:trade]).to eq(["BTC-29MAR19-2500-C"])
    end
  end
end
