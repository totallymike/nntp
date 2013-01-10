module NNTP
  Status = Struct.new(:code, :msg) do
    def to_s
      "#{self[:code]} #{self[:msg]}"
    end
  end
end