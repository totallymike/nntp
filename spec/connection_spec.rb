require_relative "spec_helper"
require 'nntp/connection'
require 'nntp/status'

describe NNTP::Connection do
  let(:sock) { double }
  let(:conn) { NNTP::Connection.new(:socket => sock)}

  describe "#query" do
    it "should properly break up multi-line data" do
      sock.stub(:gets).and_return("123 status thing\r\n", "foo\r\n", "bar\r\n", ".\r\n")
      sock.stub(:print)
      response = conn.query(:foo)
      response[:data].should eq %w(foo bar)
      response[:status][:code].should eq 123
      response[:status][:msg].should eq "status thing"
    end
    it "won't ask for data if an invalid status comes through" do
      sock.should_receive(:gets).exactly(:once).and_return "400 error"
      sock.stub(:print)
      response = conn.query :foo
      response[:status].should eq NNTP::Status.new(400, "error")
      response[:data].should be nil
    end
  end
end