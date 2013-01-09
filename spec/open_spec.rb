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
      TCPSocket.should_receive(:new).with("nntp.example.org", 119)
      conn = NNTP.open(:url => 'nntp.example.org', :port => 119)
      conn.should_not be nil
    end
    it "uses port number 119 as a default if no port is specified" do
      TCPSocket.should_receive(:new).with("nntp.example.org", 119)
      NNTP.open(:url => 'nntp.example.org')
    end
    it "can take a class as :socket_factory alongside the url and port" do
      foo = double()
      foo.should_receive(:new).with('nntp.example.org', 119)
      NNTP.open(:url => 'nntp.example.org', :socket_factory => foo)
    end
  end
end