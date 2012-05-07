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

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet

      response.should be_success
      response.should have_selector 'a', :href => root_bookmarklet_path

    end
  end

end
