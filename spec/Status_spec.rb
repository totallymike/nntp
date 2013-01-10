require_relative "spec_helper"
require "nntp/status"

describe NNTP::Status do
  describe "to_s" do
    it "should presents full message with to_s" do
      foo = NNTP::Status.new(100, "foo")
      foo.to_s.should eq "100 foo"
      bar = NNTP::Status.new(200, "bar")
      bar.to_s.should eq "200 bar"
    end
  end
end