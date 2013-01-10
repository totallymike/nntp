require_relative 'spec_helper'
require "nntp"
require 'openssl'

describe "NNTP" do
  describe "::open" do
    let(:sock) { double() }

    describe "parameters" do
      it "accepts an open socket in the parameter hash" do
        conn = NNTP.open(:socket => sock)
        conn.should_not be nil
      end

      it "will open its own socket if given a url and a port number" do
        TCPSocket.should_receive(:new).with("nntp.example.org", 120)
        conn = NNTP.open(:url => 'nntp.example.org', :port => 120)
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

      describe ":ssl => true" do
        it "builds an SSL connection if :ssl => true" do
          ssl_double = double()
          ssl_double.should_receive(:connect)
          TCPSocket.should_receive(:new).and_return { double() }
          OpenSSL::SSL::SSLSocket.should_receive(:new).and_return { ssl_double }
          NNTP.open(:url => 'ssl-nntp.example.org', :ssl => true)
        end
      end
    end

    describe "yield behavior" do
      it "yields the session object if a block is given" do
        sock.stub(:print)
        sock.stub(:gets).and_return("205 closing connection\r\n")
        sock.stub(:close)
        expect { |b| NNTP.open( {:socket => sock}, &b ) }.to yield_control
      end

      it "automatically closes the connection if a block is given" do
        conn = double()
        conn.should_receive(:quit)
        NNTP.open(:socket => sock) do |nntp|
          nntp.stub(:connection) { conn }
        end
      end
    end
  end
end