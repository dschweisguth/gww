describe Comment do
  describe '#flickrid' do
    it { does validate_presence_of :flickrid }
    it { does have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { does validate_presence_of :username }
    it { does have_readonly_attribute :username }

    it "handles non-ASCII characters" do
      non_ascii_username = '猫娘/ nekomusume'
      create :comment, username: non_ascii_username
      expect(Comment.all[0].username).to eq(non_ascii_username)
    end

  end

  describe '#comment_text' do
    it { does validate_presence_of :comment_text }
    it { does have_readonly_attribute :comment_text }

    it "handles non-ASCII characters" do
      non_ascii_text = 'π is rad'
      create :comment, comment_text: non_ascii_text
      expect(Comment.all[0].comment_text).to eq(non_ascii_text)
    end

  end

  describe '#commented_at' do
    it { does validate_presence_of :commented_at }
    it { does have_readonly_attribute :commented_at }
  end

end
