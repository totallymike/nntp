class Group
  attr_accessor :name, :first, :last, :count

  def initialize(count, first, last, name)
    @name = name
    @first = first
    @last = last
    @count = count
  end

  def inspect
    name
  end
end