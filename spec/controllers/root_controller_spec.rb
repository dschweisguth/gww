require 'spec_helper'

describe RootController do
  render_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011).getutc }
      stub(ScoreReport).order.stub!.first { ScoreReport.make :created_at => Time.local(2011).getutc }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should contain 'The most recent update from Flickr began Saturday, January 1, 0:00 PST and is still running. An update takes about six minutes.'
      response.should have_selector 'a', :href => wheresies_path(2011), :content => '2011'

    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011), :completed_at => Time.local(2001, 1, 1, 0, 6) }
      stub(ScoreReport).order.stub!.first { ScoreReport.make :created_at => Time.local(2011).getutc }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should contain 'The most recent update from Flickr began Saturday, January 1, 0:00 PST and completed at Monday, January 1, 0:06 PST.'

    end

  end

  describe '#about' do
    it 'renders the page' do
      get :about
      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => 'http://www.flickr.com/people/tma/', :content => 'Tomas Apodaca'
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'h2', :content => 'To add "View in GWW" to your bookmarks,'
    end
  end

  describe '#about_auto_mapping' do
    it 'renders the page' do
      get :about_auto_mapping
      #noinspection RubyResolve
      response.should be_success
    end
  end

end
