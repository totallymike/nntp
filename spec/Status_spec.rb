require_relative "spec_helper"
require "nntp/status"

describe NNTP::Status do
  describe "#to_s" do
    it "knows how to render the server response it represents" do
      foo = NNTP::Status.new(100, "foo")
      foo.to_s.should eq "100 foo"
      bar = NNTP::Status.new(200, "bar")
      bar.to_s.should eq "200 bar"
    end
  end
end