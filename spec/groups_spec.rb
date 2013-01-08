require "rspec"

describe "#groups" do
  before(:each) do
    @sock = double()
  end
  it "should return a list of group names" do
    conn = NNTP.open(:socket => @sock)
    conn.groups.should eq %w(alt.bin.foo alt.bin.bar)
  end
end