require 'spec_helper'

describe RootController do
  integrate_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.local(2011) }
      get :index
      response.should render_template 'index'
      response.should have_text /The most recent update from Flickr began Saturday, January 01, 00:00 PST and is still running. An update takes about six minutes./
    end

    it 'reports a completed update' do
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.local(2011), :completed_at => Time.local(2001, 1, 1, 0, 6) }
      get :index
      response.should render_template 'index'
      response.should have_text /The most recent update from Flickr began Saturday, January 01, 00:00 PST and completed at Monday, January 01, 00:06 PST./
    end

  end

  describe '#about' do
    it 'renders the page' do
      get :about
      response.should render_template 'about'
      response.should have_tag 'a[href=http://www.flickr.com/people/tma/]', :text => 'Tomas Apodaca'
    end
  end

end
