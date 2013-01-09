require "nntp/version"
require "nntp/session"
require "nntp/connection"

module NNTP
  def self.open(options)
    connection = Connection.new(options)
    session = Session.new(:connection => connection)
    if block_given?
      yield session
      session.connection.command :quit
    else
      session
    end
  end
end