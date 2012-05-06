require 'spec_helper'

describe Admin::RootController do
  render_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011) }
      stub(Photo).unfound_or_unconfirmed_count { 111 }
      stub(Photo).where.stub!.count { 222 }
      stub(Guess).group(:photo_id).stub!.count { { 1 => 2, 2 => 2 }  }
      get :index

      response.should be_success
      response.should contain 'The most recent update from Flickr began Saturday, January 1, 0:00 PST and is still running. An update takes about 20 minutes.'
      response.should contain '(111)'
      response.should contain '(222)'
      response.should contain '(2)'

    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011), :completed_at => Time.local(2001, 1, 1, 0, 6) }
      stub(Photo).unfound_or_unconfirmed_count { 111 }
      stub(Photo).where.stub!.count { 222 }
      stub(Guess).group(:photo_id).stub!.count { { 1 => 2, 2 => 2 }  }
      get :index

      response.should contain 'The most recent update from Flickr began Saturday, January 1, 0:00 PST and completed at Monday, January 1, 0:06 PST.'

    end

  end

  describe '#update_from_flickr' do
    it 'does some work and redirects' do
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
      get :update_from_flickr
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Created 1 new photos and 2 new users. Got 3 pages out of 4.'
    end
  end

  describe '#calculate_statistics_and_maps' do
    it 'does some work and redirects' do
      mock(Person).update_statistics
      mock(Photo).update_statistics
      mock(Photo).infer_geocodes
      mock_clear_page_cache
      get :calculate_statistics_and_maps
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics and maps.'
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet

      response.should be_success
      response.should have_selector 'a', :href => root_bookmarklet_path

    end
  end

end
