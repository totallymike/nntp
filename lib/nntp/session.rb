require "nntp/group"

module NNTP
  class Session
    attr_reader :connection, :group
    def initialize(options)
      @connection = options.fetch(:connection) do
        raise ArgumentError ":connection missing"
      end
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
      status = connection.command(:group, group_name)
      if status[:code] == 211
        num, low, high, name = status[:msg].split
        @group = group_factory(name, low.to_i, high.to_i, num.to_i)
      end
    end

    private
    def group_from_list(group_string)
      params = group_string.split
      name = params[0]
      low_water_mark = params[1].to_i
      high_water_mark = params[2].to_i
      group_factory(name, low_water_mark, high_water_mark)
    end

    def group_factory(*args)
      name = args[0]
      low, high, num = args[1..-1].map { |arg| arg.to_i }
      NNTP::Group.new(name, low, high, num)
    end
  end
end