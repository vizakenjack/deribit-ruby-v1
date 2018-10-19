RSpec.describe Deribit::ImmutableHeaderKey do
  let!(:immutable_header_key) {Deribit::ImmutableHeaderKey.new("test-header")}

  it "#capitalize" do
    expect(immutable_header_key.capitalize.key).to eq("test-header")
  end
end
