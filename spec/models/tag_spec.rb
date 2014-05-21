require 'spec_helper'

describe Tag do

  describe '#raw' do
    it { should validate_presence_of :raw }
    it { should have_readonly_attribute :raw }

    it "is unique for a given photo" do
      existing = create :tag, raw: 'text'
      build(:tag, photo: existing.photo, raw: 'text').should_not be_valid
    end

    it "is not unique across photos" do
      create :tag, raw: 'text'
      build(:tag, raw: 'text').should be_valid
    end

  end

  describe '#machine_tag' do
    # Can't use validate_presence_of because that validation happens before the database default value is applied
    it { should have_readonly_attribute :machine_tag }

    it "defaults to false" do
      Tag.new(raw: 'text').machine_tag.should == false
    end

    [false, true].each do |boolean|
      it "may be #{boolean}" do
        Tag.new(raw: 'text', machine_tag: boolean).should be_valid
      end
    end

    # shoulda-matchers' ensure_inclusion_of doesn't test this
    it "may not be nil" do
      Tag.new(raw: 'text', machine_tag: nil).should_not be_valid
    end

    # There does not seem to be a way to set machine_tag to a non-nil non-boolean

  end

end
