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
      @connection.stub(:query).and_yield({:code=>215}, ["alt.bin.foo 2 1 y", "alt.bin.bar 2 1 n"])
      groups = [ NNTP::Group.new('alt.bin.foo', 1, 2), NNTP::Group.new('alt.bin.bar', 1, 2)]
      nntp.groups.should eq groups
    end

    it "will return an empty list if there are no groups" do
      @connection.stub(:query).and_yield({:code => 215}, [])
      nntp.groups.should eq []
    end
  end

  describe "#group=" do
    before(:each) do
      sock.stub(:print) {}
      sock.stub(:gets) { "211 2 1 2 alt.bin.foo\r\n"}
    end

    it "can change current newsgroup with the assignment operator and a string" do
      nntp.group = "alt.bin.foo"
      nntp.group.should eq NNTP::Group.new("alt.bin.foo", 1, 2, 2)
    end
    it "does not change the current group if the new one is not found" do
      sock.stub(:gets) { "411 group not found\r\n" }
      nntp.group.should eq nil
      nntp.group = "alt.does.not.exist"
      nntp.group.should eq nil
    end
  end

  describe "#messages" do
    it "retrieves the list of messages in the current group" do
      sock.stub(:print)
      NNTP::Connection.any_instance.stub(:get_status) do
        NNTP::Status.new(211, "2 1 2 alt.bin.foo list follows")
      end
      NNTP::Connection.any_instance.stub(:get_block_data) { %w(1 2) }
      nntp.stub(:group) { NNTP::Group.new("alt.bin.foo", 1, 2, 2) }

      nntp.listgroup.should eq %w(1 2)
    end
    it "retrieves the list of messages from a given group" do
      sock.stub(:print)
      NNTP::Connection.any_instance.should_receive(:query).with(:listgroup, "alt.bin.bar").
          and_call_original
      NNTP::Connection.any_instance.stub(:get_status) do
        NNTP::Status.new(211, "3 1 3 alt.bin.bar list follows")
      end
      NNTP::Connection.any_instance.stub(:get_block_data) { %w(1 2 3) }

      nntp.listgroup("alt.bin.bar").should eq %w(1 2 3)
    end
  end
  describe "subjects" do
    let(:subjects) { ["Foo bar", "Baz bang"] }
    it "retrieves a list of subjects from the current group" do
      sock.stub(:print)
      NNTP::Connection.any_instance.stub(:get_status) do
        NNTP::Status.new(221, "Header follows")
      end
      NNTP::Connection.any_instance.stub(:get_block_data) { subjects }
      nntp.stub(:group) { NNTP::Group.new("alt.bin.foo", 1, 2, 2) }

      nntp.subjects.should eq subjects
    end
  end
end
