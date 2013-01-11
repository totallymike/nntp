require_relative 'spec_helper'
require 'nntp'

describe NNTP::Session do
  let(:sock) { double() }
  let(:nntp) { NNTP.open(:socket => sock) }

  describe "#initialize" do
    it "will raise ArgumentError if no connection is found" do
      expect { NNTP::Session.new() }.to raise_error(ArgumentError)
    end

    it "raises an error if the server presents an error message on connection" do
      NNTP::Session.any_instance.unstub(:check_initial_status)
      sock.stub(:gets) { "502 Permanently unavailable\r\n" }
      expect { NNTP.open(:socket => sock) }.to raise_error
    end
  end

  describe "authorization" do
    it "will use authinfo style authentication if a user and pass are provided" do
      NNTP::Session.any_instance.should_receive(:auth).
          with({:user => 'foo', :pass => 'bar'}).and_call_original
      NNTP::Session.any_instance.should_receive(:standard_auth)
      NNTP.open(
          :socket => sock,
          :auth => {:user => 'foo', :pass => 'bar'}
      )
    end
  end

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

      message_numbers(nntp.listgroup).should eq [1, 2]
    end
    it "retrieves the list of messages from a given group" do
      sock.stub(:print)
      NNTP::Connection.any_instance.should_receive(:query).with(:listgroup, "alt.bin.bar").
          and_call_original
      NNTP::Connection.any_instance.stub(:get_status) do
        NNTP::Status.new(211, "3 1 3 alt.bin.bar list follows")
      end
      NNTP::Connection.any_instance.stub(:get_block_data) { %w(1 2 3) }

      message_numbers(nntp.listgroup("alt.bin.bar")).should eq [1, 2, 3]
    end
  end
  describe "subjects" do
    let(:subjects) { ["1 Foo bar", "2 Baz bang"] }
    it "retrieves a list of subjects from the current group" do
      sock.stub(:print)
      NNTP::Connection.any_instance.stub(:get_status) do
        NNTP::Status.new(221, "Header follows")
      end
      NNTP::Connection.any_instance.stub(:get_block_data) { subjects }
      nntp.stub(:group) { NNTP::Group.new("alt.bin.foo", 1, 2, 2) }

      message_subjects(nntp.subjects).should eq ['Foo bar', 'Baz bang']
    end
  end
end
