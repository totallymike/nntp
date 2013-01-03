module NNTP
  Article = Struct.new(:number, :subject, :article_id) do
    def to_s
      subject
    end
  end
end
