require 'socket'
require 'nntp/status'

module NNTP
  #  Handles communication with the NNTP server.
  #
  #  Most communication with an NNTP server happens in a back-and-forth
  #  style.
  #
  #  The client sends a message to the server.  The server will respond with a status response, and sometimes with extra data. See {https://tools.ietf.org/html/rfc3977 RFC 3977} for more details.
  #
  #  This class handles this communication by providing two methods,
  #  one for use when additional data is expected, and one for when it is not.
  class Connection
    # @!attribute [r] socket
    #   The object upon which all IO takes place.
    #
    # @!attribute [r] status
    #   The most status of the most recent command.
    #   @return [NNTP::Status]

    attr_reader :socket, :status

    # (see #build_socket)
    def initialize(options)
      @socket = build_socket(options)
    end

    # Sends a message to the server, collects the the status and additional data, if successful.
    # A Hash is returned containing two keys: :status and :data.
    # :status is an {NNTP::Status}, and :data is an array containing
    # the lines from the response See example for details.
    # @example
    #   nntp.query(:list) do |status, data|
    #     $stdout.puts status
    #     data.each? do |line|
    #       $stdout.puts line
    #     end
    #   end
    #
    #   => 215 Information follows
    #   => alt.bin.foo
    #   => alt.bin.bar
    # @param query [Symbol, String] The command to send
    # @param args Any additional parameters are passed along with the command.
    # @yield The status and data from the server.
    # @yieldparam status [NNTP::Status]
    # @yieldparam data [Array<String>, nil] An array with the lines from the server.  Nil if the query failed.
    # @return [Hash] The status and requested data.
    def query(query, *args)
      command = form_message(query, args)
      send_message(command)
      status = get_status
      data = if (400..599).include? status.code
        nil
      else
        get_block_data
      end
      yield status, data if block_given?
      {:status => status, :data => data}
    end

    # Sends a message to the server and collects the status response.
    # @param (see #query)
    # @return [NNTP::Status] The server's response.
    def command(command, *args)
      command = form_message(command, args)
      send_message(command)
      get_status
    end

    # Fetch a status line from the server.
    # @return [NNTP::Status]
    def get_status
      code, message = get_line.split(' ', 2)
      @status = status_factory(code.to_i, message)
    end

    # Sends "QUIT\\r\\n" to the server, disconnects the socket.
    # @return [void]
    def quit
      command(:quit)
      socket.close
    end

    private
    def form_message(command, *args)
      message = "#{command.to_s.upcase}"
      message += " #{args.join(' ')}" unless args.empty?
    end

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

    def status_factory(*args)
      NNTP::Status.new(*args)
    end
  end
end
