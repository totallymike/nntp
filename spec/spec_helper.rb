require "rspec"
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

def message_numbers(list)
  list.map { |msg| msg.num }
end

def message_subjects(list)
  list.map {|msg| msg.subject }
end
