$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "nntp/version"
require "nntp/session"
require "nntp/connection"

module NNTP
  def self.open(options)
    connection = Connection.new(options)
    session = Session.new(:connection => connection)
    if block_given?
      yield session
      session.quit
    else
      session
    end
  end
end