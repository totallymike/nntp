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
      socket = ssl_class.new(TCPSocket.new(url, port))
      socket.connect
      socket
    end

    def ssl_class
      OpenSSL::SSL::SSLSocket
    end
  end
end
