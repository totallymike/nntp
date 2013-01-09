require_relative 'spec_helper'
require 'nntp'

describe NNTP::Session do
  let(:sock) { double() }
  let(:nntp) { NNTP.open(:socket => sock) }

  describe "#groups" do
    before(:each) do
      @connection = double()
      nntp.stub(:connection) { @connection }
    end
    it "should return a list of groups" do
      @connection.stub(:query).and_yield({:code=>215}, ["alt.bin.foo 1 2 y", "alt.bin.bar 1 2 n"])
      groups = [ NNTP::Group.new('alt.bin.foo', 1, 2), NNTP::Group.new('alt.bin.bar', 1, 2)]
      nntp.groups.should eq groups
    end

    it "will return an empty list if there are no groups" do
      @connection.stub(:query).and_yield({:code => 215}, [])
      nntp.groups.should eq []
    end
  end

  describe "#group=" do
    it "can change current newsgroup with the assignment operator and a string" do
      sock.stub(:print) {}
      sock.stub(:gets) { "211 2 1 2 alt.bin.foo"}
      nntp.group = "alt.bin.foo"
      nntp.group.should eq NNTP::Group.new("alt.bin.foo", 1, 2, 2)
    end
  end
end
