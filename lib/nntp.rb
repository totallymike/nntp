$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "nntp/version"
require "nntp/session"
require "nntp/connection"
require 'nntp/ssl_connection'

# The main entry point for this module is the open method.
#
# ::open returns an object that is an active NNTP session.
# If a block is passed to it, the session object is made available
# therein.
module NNTP
  # The main entrypoint to the module.
  #
  # @option options :url The URL of the NNTP server.
  # @option options :port (119/563) The port number of the server.
  # @option options [Boolean] :ssl (false) Connect via SSL?
  # @option options [Hash] :auth Authentication credentials and style.
  # @example Basic connection
  #   nntp = NNTP.open(
  #     :url => 'nntp.example.org',
  #     :auth => {:user => 'mike', :pass => 'soopersecret'}
  #   )
  #   nntp.quit
  # @example Pass a block
  #   # Automatically closes connection
  #   NNTP.open(:url => 'nntp.example.org') do |nntp|
  #     nntp.group = 'alt.bin.foo'
  #   end
  # @return [NNTP::Session] the active NNTP session
  def self.open(options)
    if options[:ssl]
      connection = SSLConnection.new(options)
    else
      connection = Connection.new(options)
    end

    session = Session.new(:connection => connection)

    session.auth(options[:auth]) if options[:auth]

    if block_given?
      yield session
      session.quit
    else
      session
    end
  end
end
