require 'spec_helper'

describe RootController do
  render_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make created_at: Time.local(2011).getutc }
      stub(ScoreReport).order.stub!.first { ScoreReport.make created_at: Time.local(2011).getutc }
      get :index

      response.should be_success
      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and is still running. An update takes about 20 minutes.'
      response.body.should have_link '2011', href: wheresies_path(2011)

    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.make created_at: Time.local(2011), completed_at: Time.local(2001, 1, 1, 0, 6) }
      stub(ScoreReport).order.stub!.first { ScoreReport.make created_at: Time.local(2011).getutc }
      get :index

      response.should be_success
      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and completed at Monday, January  1,  0:06 PST.'

    end

  end

  describe '#about' do
    it 'renders the page' do
      get :about
      response.should be_success
      response.body.should have_link 'Tomas Apodaca', href: 'https://www.flickr.com/people/tma/'
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      response.should be_success
      response.body.should have_css 'h2', text: 'To add "View in GWW" to your bookmarks,'
    end
  end

  describe '#about_auto_mapping' do
    it 'renders the page' do
      get :about_auto_mapping
      response.should be_success
    end
  end

end
