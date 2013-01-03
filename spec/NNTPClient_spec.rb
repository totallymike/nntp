require_relative 'spec_helper'
require 'socket'

describe NNTPClient do
  before (:each) do
    @sock = double()
  end

  let (:nntp) do
    NNTPClient.new(:socket => @sock)
  end

  it 'should have a version number' do
    NNTPClient::VERSION.should_not be_nil
  end

  describe '::new' do
    it 'can create its own socket given a url and port number' do
      TCPSocket.should_receive(:new).exactly(:once)

      TCPSocket.stub(:new).and_return @sock
      NNTPClient.new(:url => 'nntp.example.org', :url => 119)
    end

    it 'uses port number 119 as a default' do
      TCPSocket.should_receive(:new).with('nntp.example.org', 119)
      NNTPClient.new(:url => 'nntp.example.org')
    end

    it 'will raise ArgumentError if no :url is found' do
      expect { NNTPClient.new({}) }.to raise_error ArgumentError
    end

    it 'can use a custom socket factory' do
      url = 'nntp.example.org'
      port = 119
      factory = double()
      factory.should_receive(:new).with(url, port)
      NNTPClient.new({
          :url => url,
          :port => port,
          :socket_factory => factory
      })
    end

    it 'Can accept a given socket' do
      @sock.stub(:foo) { 'See? It works.' }
      client = NNTPClient.new(:socket => @sock)
      client.socket.foo.should eq 'See? It works.'
    end
  end

  describe '#groups' do
    let (:groups) do
      ["215 list of newsgroups follows\r\n", "alt.bin.foo\r\n",
       "alt.bin.bar\r\n", ".\r\n"]
    end

    before(:each) do
      @sock.should_receive(:print).with("LIST\r\n")
      @sock.should_receive(:gets).exactly(4).times.and_return(groups[0], groups[1], groups[2], groups[3])
    end
    it 'can request a list of groups' do
      groups_response = nntp.groups
      groups_response.should eq %w(alt.bin.foo alt.bin.bar)
      nntp.groups.should eq %w(alt.bin.foo alt.bin.bar)
    end
  end

  describe '#auth' do
    before(:each) do
      @sock.should_receive(:print).with("AUTHINFO USER foo\r\n")
      @sock.should_receive(:print).with("AUTHINFO PASS bar\r\n")
    end
    it 'can use standard AUTHINFO authentication' do
      nntp.auth :user => 'foo', :pass => 'bar'
    end
  end
  describe '#messages' do
    before(:each) do
      # @sock.should_receive(:print).with("XHDR Subject 1-\r\n")
      @sock.should_receive(:gets).exactly(:once).
          and_return "221 Subject data follows\r\n"
      #@sock.should_receive(:print).with
      nntp.stub(:get_data_block).and_return(
          ["1 foo", "2 bar"]
      )

      nntp.stub(:current_group) { NNTP::Group.new(2,1,2, 'alt.bin.foo.bar') }
      nntp.stub(:send_message)
    end
    it 'can list the messages in current group by subject' do
      articles = nntp.articles.map {|article| article.to_s}
      articles.should eq %w(foo bar)
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
      nntp.current_group.name.should eq group
    end
  end
end
