require 'spec_helper'

describe FlickrUpdate do

  describe '#member_count' do
    it { should validate_presence_of :member_count }
    it { should validate_non_negative_integer :member_count }
    it { should have_readonly_attribute :member_count }
  end

  describe '.latest' do
    it "returns the most recent update" do
      FlickrUpdate.make
      most_recent_update = FlickrUpdate.make
      FlickrUpdate.latest.should == most_recent_update
    end
  end

  describe '.create_before_and_update_after' do
    it "creates an update, does something and updates the update with the time it was completed" do
      stub(FlickrCredentials).request('flickr.groups.getInfo') { {
        'group'=> [ {
          'members'=>['1492']
        } ]
      } }
      the_block_ran = false
      FlickrUpdate.create_before_and_update_after { the_block_ran = true }

      the_block_ran.should be_true
      updates = FlickrUpdate.all
      updates.size.should == 1
      update = updates[0]
      update.member_count.should == 1492
      update.completed_at.should_not be_nil

    end
  end

end
