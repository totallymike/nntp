require_relative 'spec_helper'
require "nntp"

describe "NNTP" do

  describe "::open" do
    it "accepts an open socket in the parameter hash" do
      sock = double()
      conn = NNTP.open(:socket => sock)
      conn.should_not be nil
    end
    it "will open its own socket if given a url and a port number" do
      TCPSocket.should_receive :new
      conn = NNTP.open(:url => 'nntp.example.org', :port => 119)
      conn.should_not be nil
    end
  end
end