$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "nntp/version"
require "nntp/session"
require "nntp/connection"
require 'nntp/ssl_connection'

module NNTP
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