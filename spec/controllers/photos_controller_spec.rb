require 'spec_helper'

describe PhotosController do
  integrate_views
  without_transactions

  describe '#list' do
    it 'renders the page' do
      sorted_by_param = 'username'
      order_param = '+'
      page_param = '1'

      stub(Photo).count { 1 }

      # Mock methods from will_paginate's version of Array
      paginated_photos = [ Photo.make ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).all_sorted_and_paginated(sorted_by_param, order_param, page_param, 30) { paginated_photos }
      get :index, :sorted_by => sorted_by_param, :order => order_param, :page => page_param

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 photos'
      response.should have_tag 'a[href=/photos/sorted-by/username/order/-/page/1]', :text => 'posted by'
      response.should have_tag 'a[href=/people/show/0]', :text => 'poster_username'

    end
  end

  describe '#unfound' do
    it 'renders the page' do
      stub(Photo).unfound_or_unconfirmed { [ Photo.make ] }
      get :unfound

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=http://www.flickr.com/photos/poster_person_flickrid/photo_flickrid/in/pool-guesswheresf/]', :text => 'Flickr'
      response.should have_tag 'a[href=/photos/0]', :text => 'GWW'
      response.should have_tag 'a[href=/people/show/0]', :text => 'poster_username'

    end
  end

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.utc(2011) }
      stub(Photo).unfound_or_unconfirmed { [ Photo.make ] }
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
      photo = Photo.make :id => 1, :dateadded => Time.local(2010)
      guess = Guess.make :photo => photo
      photo.guesses << guess
      stub(Photo).find { photo }
      #noinspection RubyResolve
      stub(Comment).find_all_by_photo_id(photo) { [ Comment.make :photo => photo ] }
      get :show, :id => photo.id

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
      response.should have_tag 'strong', :text => 'commenter_username'
      response.should have_text /comment text/

    end
  end

end
