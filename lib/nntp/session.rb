require "nntp/group"

module NNTP
  class Session
    attr_reader :connection
    def initialize(options)
      @connection = options.fetch(:connection) do
        raise ArgumentError ":connection missing"
      end
    end
    def groups
      group_list = []
      connection.query :list do |status, list|
        list.each do |group|

          group_list << build_group(group)
        end
      end
      group_list
    end

    private
    def build_group(group_string)
      params = group_string.split
      name = params[0]
      first_msg = params[1].to_i
      last_msg = params[2].to_i
      can_write = params[3]
      group.new(name, first_msg, last_msg, can_write)
    end

    def group
      NNTP::Group
    end
  end
end