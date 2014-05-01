require 'spec_helper'

describe Admin::RootController do
  render_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make created_at: Time.local(2011) }
      stub(Photo).unfound_or_unconfirmed_count { 111 }
      stub(Photo).where.stub!.count { 222 }
      stub(Guess).group(:photo_id).stub!.count { { 1 => 2, 2 => 2 }  }
      get :index

      response.should be_success
      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and is still running. An update takes about 20 minutes.'
      response.body.should include '(111)'
      response.body.should include '(222)'
      response.body.should include '(2)'

    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.make created_at: Time.local(2011), completed_at: Time.local(2001, 1, 1, 0, 6) }
      stub(Photo).unfound_or_unconfirmed_count { 111 }
      stub(Photo).where.stub!.count { 222 }
      stub(Guess).group(:photo_id).stub!.count { { 1 => 2, 2 => 2 }  }
      get :index

      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and completed at Monday, January  1,  0:06 PST.'

    end

  end

  describe '#update_from_flickr' do
    it 'calls the equivalent CronJob method and redirects' do
      mock(CronJob).update_from_flickr { "The message" }
      get :update_from_flickr
      response.should redirect_to admin_root_path
      flash[:notice].should == "The message"
    end
  end

  describe '#calculate_statistics_and_maps' do
    it 'calls the equivalent CronJob method and redirects' do
      mock(CronJob).calculate_statistics_and_maps { "The message" }
      get :calculate_statistics_and_maps
      response.should redirect_to admin_root_path
      flash[:notice].should == "The message"
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet

      response.should be_success
      response.body.should have_css %Q(a[href="#{root_bookmarklet_path}"])

    end
  end

end
