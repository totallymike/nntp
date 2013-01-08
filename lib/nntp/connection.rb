require 'socket'

module NNTP
  class Connection
    attr_reader :socket
    def initialize(options)
      @socket = build_socket(options)
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

  end
end