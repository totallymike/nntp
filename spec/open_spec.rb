require_relative 'spec_helper'
require "nntp"

describe "NNTP" do

  describe "::open" do
    it "accepts an open socket in the parameter hash" do
      sock = double()
      conn = NNTP.open(:socket => sock)
      conn.should_not be nil
    end
    it "can also accept a url and a port" do
      conn = NNTP.open(:url => 'nntp.example.org', :port => 119)
      conn.should_not be nil
    end
  end
end