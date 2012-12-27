require 'socket'
require "NNTPClient/version"

class NNTPClient
  attr_reader :socket, :status, :current_group,
              :groups

  def initialize(url, port=119)
    @socket = TCPSocket.new(url, port)
    @current_group = nil
    @status = nil
    @groups = nil
  end

  def list_groups
    send_message "LIST"
    status = get_status
    return nil unless status[:code] == 215

    self.groups = get_data_block
  end

  def group(group)
    send_message "GROUP #{group}"
    self.status = get_status
    if status[:code] == 211
      self.current_group = status[:params][-1]
    end
  end

  private
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
