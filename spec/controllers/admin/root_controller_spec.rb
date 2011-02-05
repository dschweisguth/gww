require 'spec_helper'

describe Admin::RootController do
  integrate_views

  describe '#index' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.local(2011) }
      stub(Photo).unfound_or_unconfirmed_count { 111 }
      stub(Photo).count { 222 }
      stub(Guess).count { { 1 => 2, 2 => 2 }  }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /The most recent update from Flickr began Saturday, January 01, 00:00 PST and is still running. An update takes about six minutes./
      response.should have_text /\(111\)/
      response.should have_text /\(222\)/
      response.should have_text /\(2\)/

    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/bookmarklet]'
    end
  end

end
