require 'spec_helper'

describe PhotosController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      SORTED_BY_PARAM = 'username'
      ORDER_PARAM = '+'
      PAGE_PARAM = '1'

      # Mock methods from will_paginate's version of Array
      paginated_photos = [ Photo.new_for_test ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).all_sorted_and_paginated(SORTED_BY_PARAM, ORDER_PARAM, PAGE_PARAM, 30) { paginated_photos }
      get :list, :sorted_by => 'username', :order => ORDER_PARAM, :page => PAGE_PARAM

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/photos/list/sorted-by/username/order/-/page/1]', :text => 'posted by'
      response.should have_tag 'a[href=/people/show]', :text => 'poster_username'

    end
  end

  describe '#unfound' do
    it 'renders the page' do
      stub(Photo).unfound_or_unconfirmed { [ Photo.new_for_test ] }
      get :unfound

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=http://www.flickr.com/photos/poster_person_flickrid/photo_flickrid/in/pool-guesswheresf/]', :text => 'Flickr'
      response.should have_tag 'a[href=/photos/show]', :text => 'GWW'
      response.should have_tag 'a[href=/people/show]', :text => 'poster_username'

    end
  end

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.utc(2011) }
      stub(Photo).unfound_or_unconfirmed { [ Photo.new_for_test ] }
      get :unfound_data

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'photos[updated_at=1293840000]' do
        with_tag 'photo[posted_by=poster_username]'
      end

    end
  end

  describe '#show' do
    it 'renders the page' do
      photo = Photo.new_for_test :dateadded => Time.local(2010)
      guess = Guess.new_for_test :photo => photo
      photo.guesses << guess
      stub(Photo).find { photo }
      #noinspection RubyResolve
      stub(Comment).find_all_by_photo_id { [ Comment.new_for_test :photo => photo ] }
      get :show, :id => '1'

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=http://www.flickr.com/photos/poster_person_flickrid/photo_flickrid/in/pool-guesswheresf/]' do
        with_tag 'img[src=http://farm0.static.flickr.com/server/photo_flickrid_secret.jpg]'
      end
      response.should have_text /Added to the group at 12:00 AM, January 01, 2010/
      response.should have_text /This photo is unfound./
      response.should have_tag 'table' do
        with_tag 'td', :text => 'guesser_username'
        with_tag 'td', :text => 'guess text'
      end
      response.should have_tag 'strong', :text => 'comment_username says:'
      response.should have_text /comment text/

    end
  end

  describe '#view_in_gww' do
    it 'redirects to the given photo' do
      photo = Photo.new_for_test
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid('0123456789') { photo }
      get :view_in_gww, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'
      response.should redirect_to :controller => 'photos', :action => 'show', :id => photo
    end

    it 'punts unknown photo Flickr IDs' do
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :view_in_gww, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Sorry/

    end

    it 'punts unknown URLs' do
      get :view_in_gww, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Hmmm/

    end

  end

end
