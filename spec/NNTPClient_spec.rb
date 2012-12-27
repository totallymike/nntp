require_relative 'spec_helper'
require 'socket'

describe NNTPClient do
  before (:each) do
    @sock = double()
  end

  let (:nntp) do
    TCPSocket.stub(:new).and_return @sock
    NNTPClient.new('nntp.example.com', 119)
  end

  it 'should have a version number' do
    NNTPClient::VERSION.should_not be_nil
  end

  describe '#groups' do

    let (:groups) do
      ["215 list of newsgroups follows\r\n", "alt.bin.foo\r\n",
       "alt.bin.bar\r\n", ".\r\n"]
    end

    before(:each) do
      @sock.should_receive(:print).with("LIST\r\n")
      @sock.should_receive(:gets).and_return(groups[0], groups[1], groups[2], groups[3])
    end
    it 'can request a list of groups' do
      groups_response = nntp.list_groups
      groups_response.should eq %w(alt.bin.foo alt.bin.bar)
      nntp.groups.should eq %w(alt.bin.foo alt.bin.bar)
    end
  end

  describe '#group' do
    let (:group) do 'alt.bin.foo.bar' end

    before(:each) do
      @sock.should_receive(:print).with("GROUP #{group}\r\n")
      @sock.should_receive(:gets).and_return("211 2 1 2 alt.bin.foo.bar\r\n")
    end
    it 'can select a group from the server' do
      nntp.group group
      nntp.status[:code].should eq 211
      nntp.current_group.should eq group
    end
  end
end
