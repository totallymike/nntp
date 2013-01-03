require 'socket'
require_relative 'group'
require_relative 'article'
require "NNTPClient/version"

class NNTPClient
  attr_reader :socket, :status, :current_group

  def initialize(options = {})
    @socket = open_socket(options)
    init_attributes
  end

  def groups
    @groups ||= list_groups
  end

  def group(group)
    send_message "GROUP #{group}"
    self.status = get_status
    if status[:code] == 211
      self.current_group = create_group(status)
    end
  end

  def articles
    @articles ||= fetch_articles
  end

  def auth(options = {})
    send_message "AUTHINFO USER #{options[:user]}"
    send_message "AUTHINFO PASS #{options[:pass]}"
  end
  private
  def fetch_articles
    send_message "XHDR Subject #{current_group.first}-"
    self.status = get_status
    return nil unless status[:code] == 221
    get_data_block.map do |line|
      article_id, article_subject = line.split(' ', 2)
      NNTP::Article.new(article_id, article_subject)
    end
  end

  def init_attributes
    @current_group = nil
    @status = nil
    @groups = nil
    @articles = nil
  end

  def create_group(status)
    params = status[:params]
    # TODO: This is ugly
    NNTP::Group.new(*params[1..-1])
  end

  def open_socket(options)
    options.fetch(:socket) {
      url = options.fetch(:url) { raise ArgumentError, ':url is required' }
      port = options.fetch(:port, 119)
      socket_factory = options.fetch(:socket_factory) { TCPSocket }
      socket_factory.new(url, port)
    }
  end

  def list_groups
    send_message "LIST"
    status = get_status
    return nil unless status[:code] == 215

    get_data_block
  end

  def groups=(list=[])
    @groups = list
  end

  def status=(status)
    @status = status
  end

  def current_group=(group)
    @current_group = group
  end

  def get_status
    line = get_line
    {
      :code => line[0..2].to_i,
      :message => line[3..-1].lstrip,
      :params => line.split
    }
  end

  def get_data_block
    lines = []
    current_line = get_line
    until current_line == '.'
      lines << current_line
      current_line = get_line
    end
    lines
  end

  def get_line
    socket.gets().chomp
  end

  def send_message(msg)
    socket.print "#{msg}\r\n"
  end
end
