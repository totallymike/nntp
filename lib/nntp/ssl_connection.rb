require_relative 'connection'
require 'openssl'
require 'socket'

module NNTP
  class SSLConnection < Connection
    private
    def build_socket(args)
      url = args.fetch(:url) do
        raise ArgumentError ":url missing"
      end
      port = args.fetch(:port, 563)
      socket = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(url, port))
      socket.connect
      socket
    end
  end
end
