RSpec.describe Deribit::Request do
  let(:key){"BxxwbXRLmYid"}
  let(:secret){"AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO"}
  let(:credentials){Deribit::Credentials.new(key, secret)}
  let(:request){Deribit::Request.new(credentials)}
  let(:invalid_request){Deribit::Request.new(Deribit::Credentials.new("BxxwbXRLmYid","122"))}

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
        expect{invalid_request.send(path: '/api/v1/private/account')}.to raise_error(Deribit::Error, "Failed: authorization_required")
      end
    end
  end
end
