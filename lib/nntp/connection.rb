require 'socket'
require 'nntp/status'

module NNTP
  class Connection
    attr_reader :socket
    def initialize(options)
      @socket = build_socket(options)
    end

    def query(query)
      command = query.to_s.upcase
      send_message(command)
      status = get_status
      data = get_block_data
      yield status, data if block_given?
      {:status => status, :data => data}
    end

    def command(command, arguments = nil)
      command = command.to_s.upcase
      command += " #{arguments}" if arguments
      send_message(command)
      get_status
    end

    private
    def build_socket(options)
      options.fetch(:socket) do
        url = options.fetch(:url) do
          raise ArgumentError "Must have :url or :socket"
        end
        port = options.fetch(:port, 119)
        socket_factory = options.fetch(:socket_factory) { TCPSocket }
        socket_factory.new(url, port)
      end
    end

    def send_message(message)
      socket.print "#{message}\r\n"
    end

    def get_line
      line = socket.gets
      line.chomp
    end

    def get_block_data
      data = []
      line = get_line
      until line == '.'
        data << line
        line = get_line
      end
      data
    end

    def get_status
      code, message = get_line.split(' ', 2)
      status.new(code.to_i, message)
    end

    def status
      NNTP::Status
    end
  end
end