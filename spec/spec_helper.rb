require "rspec"
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RSpec.configure do |config|
  config.before(:each) do
    NNTP::Session.any_instance.stub(:check_initial_status) { nil }
  end
end

def message_numbers(list)
  list.map { |msg| msg.num }
end

def message_subjects(list)
  list.map {|msg| msg.subject }
end
