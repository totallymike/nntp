module NNTP
  class Session
    attr_reader :connection
    def initialize(options)
      @connection = options.fetch(:connection) do
        raise ArgumentError ":connection missing"
      end
    end
    def groups
      %w(alt.bin.foo alt.bin.bar)
    end
  end
end