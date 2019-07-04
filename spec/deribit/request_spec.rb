RSpec.describe Deribit::Request do
  let(:key) {"BxxwbXRLmYid"}
  let(:secret) {"AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO"}
  let(:request) {Deribit::Request.new(key, secret, test: true)}
  let(:invalid_request) {Deribit::Request.new('123', '456', test: true)}

  it "#generate_signature" do
    signature = request.generate_signature('/api/v1/private/account', {ext: true})
    expect(signature).to include(key)
    expect(signature.split(".").size).to eq(3)
  end

  describe "#send" do
    it ":ok" do
      VCR.use_cassette 'request/send' do
        expect(request.send(path: '/api/v1/private/account')).to_not include('error')
      end
    end

    it ":error" do
      VCR.use_cassette 'request/send_error' do
        expect{invalid_request.send(path: '/api/v1/private/account')}.to raise_error(Deribit::Error)
      end
    end
  end
end
