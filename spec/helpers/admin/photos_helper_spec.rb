describe Admin::PhotosHelper do
  describe '#wrap_if' do
    it "wraps if the condition is true" do
      helper.wrap_if(true, '<begin>', '<end>') { 'content' }.should == '<begin>content<end>'
    end

    it "doesn't wrap if the condition is false" do
      helper.wrap_if(false, '<begin>', '<end>') { 'content' }.should == 'content'
    end

  end
end
