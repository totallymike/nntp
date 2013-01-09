require_relative "spec_helper"
require 'nntp/connection'

describe NNTP::Connection do
  let(:sock) { double }
  let(:conn) { NNTP::Connection.new(:socket => sock)}

  describe "#query" do
    it "should properly break up multi-line data" do
      sock.stub(:gets).and_return("123 status thing\r\n", "foo\r\n", "bar\r\n", ".\r\n")
      sock.stub(:print)
      response = conn.query(:foo)
      response[:data].should eq ['foo', 'bar']
      response[:status][:code].should eq 123
      response[:status][:msg].should eq "status thing"
    end
  end
end