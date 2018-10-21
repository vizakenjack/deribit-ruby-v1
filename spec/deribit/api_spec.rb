RSpec.describe Deribit::API do
  let(:key){"BxxwbXRLmYid"}
  let(:secret){"AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO"}
  let!(:api){Deribit::API.new(key, secret)}


  it "#account" do
    VCR.use_cassette 'request/account' do
      expect(api.account).to include("balance")
    end
  end

  it "#getinstruments" do
    VCR.use_cassette 'request/getinstruments' do
      expect(api.getinstruments.first).to include("instrumentName")
    end
  end

  it "#getorderbook" do
    VCR.use_cassette 'request/getorderbook' do
      result = api.getorderbook("BTC-19OCT18-5250-C")
      expect(result).to include("asks")
      expect(result).to include("bids")
    end
  end

  it "#index" do
    VCR.use_cassette 'request/index1' do
      result = api.index
      expect(result).to include("btc")
      expect(result).to include("edp")
    end
  end

  it "#getcurrencies" do
    VCR.use_cassette 'request/getcurrencies' do
      result = api.getcurrencies
      expect(result.first).to include("currency")
    end
  end

  it "#getlasttrades" do
    VCR.use_cassette 'request/getlasttrades' do
      result = api.getlasttrades("BTC-19OCT18-5250-C")
      expect(result.first).to include("direction")
      expect(result.first).to include("indexPrice")
      expect(result.first).to include("quantity")
    end
  end

  it "#getsummary" do
    VCR.use_cassette 'request/getsummary' do
      result = api.getsummary("BTC-19OCT18-5250-C")
      expect(result).to include("volume")
      expect(result).to include("uPx")
      expect(result).to include("high")
    end
  end

  it "#buy" do
    VCR.use_cassette 'request/buy' do
      result = api.buy("BTC-26OCT18", 1, nil, type: "market")
      expect(result).to include("order")
      expect(result).to include("trades")
    end
  end

  it "#sell" do
    VCR.use_cassette 'request/sell' do
      result = api.sell("BTC-26OCT18", 1, 0.02)
      expect(result).to include("order")
      expect(result).to include("trades")
    end
  end

  it "#edit" do
    VCR.use_cassette 'request/edit' do
      result = api.edit("1780063496", 2, 0.02)
      expect(result).to include("order")
      expect(result).to include("trades")
    end
  end

  it "#cancel" do
    VCR.use_cassette 'request/cancel' do
      result = api.cancel("1779991913")
      expect(result).to include("order")
      expect(result["order"]["state"]).to eq("cancelled")
    end
  end

  it "#getopenorders" do
    VCR.use_cassette 'request/getopenorders' do
      result = api.getopenorders("BTC-26OCT18-6250-C")
      expect(result.first).to include("orderId")
    end
  end

  it "#positions" do
    VCR.use_cassette 'request/positions' do
      result = api.positions
      expect(result.first).to include("instrument")
    end
  end

  it "#orderhistory" do
    VCR.use_cassette 'request/orderhistory' do
      result = api.orderhistory
      expect(result.first).to include("instrument")
    end
  end

  it "#orderhistory with count" do
    VCR.use_cassette 'request/orderhistory_count' do
      result = api.orderhistory(20)
      expect(result.first).to include("instrument")
    end
  end

  it "#tradehistory" do
    VCR.use_cassette 'request/tradehistory' do
      result = api.tradehistory
      expect(result.first).to include("instrument")
    end
  end

end
