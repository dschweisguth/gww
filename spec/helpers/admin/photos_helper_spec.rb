describe Admin::PhotosHelper do
  describe '#wrap_if' do
    it "wraps if the condition is true" do
      expect(helper.wrap_if(true, '<begin>', '<end>') { 'content' }).to eq('<begin>content<end>')
    end

    it "doesn't wrap if the condition is false" do
      expect(helper.wrap_if(false, '<begin>', '<end>') { 'content' }).to eq('content')
    end

  end
end
