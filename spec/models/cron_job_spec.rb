require 'spec_helper'

describe CronJob do

  describe '#update_from_flickr' do
    it "does some work" do
      mock_clear_page_cache 2
      stub(FlickrCredentials).groups_get_info(:group_id => FlickrCredentials::GROUP_ID) { {
        'group'=> [ {
          'members' => [ '1492' ]
        } ]
      } }
      update = FlickrUpdate.make :member_count => 1492
      mock(FlickrUpdate).create!(:member_count => '1492') { update }
      mock(Photo).update_all_from_flickr { [ 1, 2, 3, 4 ] }
      mock(Person).update_all_from_flickr
      stub(Time).now { Time.utc(2011) }
      mock(update).update_attribute :completed_at, Time.utc(2011)
      CronJob.update_from_flickr
    end
  end

  describe '#calculate_statistics_and_maps' do
    it "does some work" do
      mock(Person).update_statistics
      mock(Photo).update_statistics
      mock(Photo).infer_geocodes
      mock_clear_page_cache
      CronJob.calculate_statistics_and_maps
    end
  end

end
