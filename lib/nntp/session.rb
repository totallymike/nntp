require "nntp/group"
require 'nntp/message'

module NNTP
  class Session
    attr_reader :connection, :group
    def initialize(options)
      @group = nil
      @connection = options.fetch(:connection) do
        raise ArgumentError ":connection missing"
      end
      check_initial_status
    end

    def auth(args)
      auth_method = args.fetch(:type, :standard)
      standard_auth(args) if auth_method == :standard
    end

    def groups
      group_list = []
      connection.query :list do |status, list|
        list.each do |group|
          group_list << group_from_list(group)
        end if status[:code] == 215
      end
      group_list
    end

    def group=(group_name)
      connection.command(:group, group_name)
      if status[:code] == 211
        num, low, high, name = status[:msg].split
        @group = group_factory(name, low.to_i, high.to_i, num.to_i)
      end
    end

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

    def status
      connection.status
    end

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
      raise "#{status}" if [400, 502].include? status.code
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
  end
end