require "nntp/group"
require 'nntp/message'

module NNTP
  # Most of the action happens here.  This class describes the
  # object the user interacts with the most.
  # It is constructed by NNTP::open, but you can build your own
  # if you like.
  class Session
    attr_reader :connection, :group
    # @option options [NNTP::Connection, NNTP::SSLConnection] :connection
    #   The connection object.
    def initialize(options)
      @group = nil
      @connection = options.fetch(:connection) do
        raise ArgumentError ":connection missing"
      end
      check_initial_status
    end

    # Authenticate to the server.
    #
    # @option args :user Username
    # @option args :pass Password
    # @option args :type (:standard)
    #   Which authentication type to use.  Currently only
    #   standard is supported.
    # @return [NNTP::Status]
    def auth(args)
      auth_method = args.fetch(:type, :standard)
      standard_auth(args) if auth_method == :standard
    end

    # Fetches and returns the list of groups from the server or, if it
    # has already been fetched, returns the saved list.
    # @return [Array<NNTP::Group>]
    def groups
      @groups ||= fetch_groups
    end

    # @!attribute [rw] group
    #   Retrieves current group, or
    #   sets current group, server-side, to assigned value.
    #   @param [String] group_name The name of the group to be selected.
    #   @return [NNTP::Group] The current group.
    def group=(group_name)
      connection.command(:group, group_name)
      if status[:code] == 211
        num, low, high, name = status[:msg].split
        @group = group_factory(name, low.to_i, high.to_i, num.to_i)
      end
    end

    # Fetch list of message numbers from a given group.
    # @param group  The name of the group to list defaults to {#group #group.name}
    # @param range (nil) If given, specifies the range of messages to retrieve
    # @return [Array<NNTP::Message>] The list of messages
    #   (only the message numbers will be populated).
    # @see https://tools.ietf.org/html/rfc3977#section-6.1.2
    def listgroup(*args)
      messages = []
      connection.query(:listgroup, *args) do |status, data|
        if status[:code] == 211
          data.each do |line|
            message = Message.new
            message.num = line.to_i
            messages << message
          end
        end
      end
      messages
    end

    # Fetch list of messages from current group.
    # @return [Array<NNTP::Message>] The list of messages
    #   (The numbers AND the subjects will be populated).
    def subjects
      subjects = []
      range ="#{group[:first_message]}-"
      connection.query(:xhdr, "Subject", range) do |status, data|
        if status[:code] == 221
          data.each do |line|
            message = Message.new
            message.num, message.subject = line.split(' ', 2)
            subjects << message
          end
        end
      end
      subjects
    end

    # The most recent status from the server.
    def status
      connection.status
    end

    # (see NNTP::Connection#quit)
    def quit
      connection.quit
    end
    private
    def standard_auth(args)
      connection.command(:authinfo, "USER #{args[:user]}")
      if status[:code] == 381
        connection.command(:authinfo, "PASS #{args[:pass]}")
      elsif [281, 482, 502].include? status[:code]
        status
      end
    end

    def check_initial_status
      raise "#{status}" if [400, 502].include? connection.get_status.code
    end

    def group_from_list(group_string)
      params = group_string.split
      name = params[0]
      high_water_mark = params[1].to_i
      low_water_mark = params[2].to_i
      group_factory(name, low_water_mark, high_water_mark)
    end

    def group_factory(*args)
      name = args[0]
      low, high, num = args[1..-1].map { |arg| arg.to_i }
      NNTP::Group.new(name, low, high, num)
    end

    def fetch_groups
      group_list = []
      connection.query :list do |status, list|
        list.each do |group|
          group_list << group_from_list(group)
        end if status[:code] == 215
      end
      group_list
    end
  end
end
