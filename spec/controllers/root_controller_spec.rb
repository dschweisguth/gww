require 'spec_helper'

describe RootController do
  integrate_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011) }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /The most recent update from Flickr began Saturday, January 01, 00:00 PST and is still running. An update takes about six minutes./

    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.local(2011), :completed_at => Time.local(2001, 1, 1, 0, 6) }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /The most recent update from Flickr began Saturday, January 01, 00:00 PST and completed at Monday, January 01, 00:06 PST./

    end

  end

  describe '#about' do
    it 'renders the page' do
      get :about
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=http://www.flickr.com/people/tma/]', :text => 'Tomas Apodaca'
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'p', :text => 'To add "View in GWW" to your bookmarks,'
    end
  end

end
