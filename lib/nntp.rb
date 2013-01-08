require "nntp/version"
require "nntp/session"
require "nntp/connection"

module NNTP
  def self.open(options)
    connection = Connection.new(options)
    Session.new(:connection => connection)
  end
end