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
  end

end
