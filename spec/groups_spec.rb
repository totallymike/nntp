require "rspec"
require_relative 'spec_helper'

describe "#groups" do
  let(:conn) do
    @sock = double()
    NNTP.open(:socket => @sock)
  end

  before(:each) do
    @connection = double()
    conn.stub(:connection) { @connection }
  end
  it "should return a list of groups" do
    @connection.stub(:query).and_yield({:code=>215}, ["alt.bin.foo 1 2 y", "alt.bin.bar 1 2 n"])
    groups = [ NNTP::Group.new('alt.bin.foo', 1, 2, 'y'), NNTP::Group.new('alt.bin.bar', 1, 2, 'n')]
    conn.groups.should eq groups
  end

  it "will return an empty list if there are no groups" do
    @connection.stub(:query).and_yield({:code => 215}, [])
    conn.groups.should eq []
  end

end