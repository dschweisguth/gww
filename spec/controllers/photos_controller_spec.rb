require 'spec_helper'

describe PhotosController do
  render_views

  describe '#list' do
    it 'renders the page' do
      sorted_by_param = 'username'
      order_param = '+'
      page_param = '1'

      stub(Photo).count { 1 }

      # Mock methods from will_paginate's version of Array
      photo = Photo.make
      paginated_photos = [ photo ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).all_sorted_and_paginated(sorted_by_param, order_param, page_param, 30) { paginated_photos }
      get :index, :sorted_by => sorted_by_param, :order => order_param, :page => page_param

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'h1', :content => '1 photos'
      response.should have_selector 'a', :href => photos_path('username', '-', 1), :content => 'posted by'
      response.should have_selector 'a', :href => person_path(photo.person), :content => 'poster_username'

    end
  end

  describe '#map' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(controller).map_photos { json }
      get :map

      assigns[:json].should == json.to_json

      #noinspection RubyResolve
      response.should be_success
      response.should contain /GWW\.config = #{Regexp.escape assigns[:json]};/

    end
  end

  describe '#map_json' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(controller).map_photos { json }
      get :map_json

      #noinspection RubyResolve
      response.should be_success
      response.body.should == json.to_json

    end
  end

  describe '#map_photos' do
    it "returns an unfound photo" do
      photo = Photo.make :id => 14
      map_photos_returns PhotosController::INITIAL_MAP_BOUNDS, photo, 'FFFF00', '?'
    end

    it "configures an unconfirmed photo like an unfound" do
      photo = Photo.make :id => 14, :game_status => 'unconfirmed'
      map_photos_returns PhotosController::INITIAL_MAP_BOUNDS, photo, 'FFFF00', '?'
    end

    it "configures a found differently" do
      photo = Photo.make :id => 14, :game_status => 'found'
      map_photos_returns PhotosController::INITIAL_MAP_BOUNDS, photo, '008000', '!'
    end

    it "configures a revealed photo differently" do
      photo = Photo.make :id => 14, :game_status => 'revealed'
      map_photos_returns PhotosController::INITIAL_MAP_BOUNDS, photo, 'E00000', '-'
    end

    it "echos non-default bounds" do
      photo = Photo.make :id => 14
      controller.params[:sw] = '1,2'
      controller.params[:ne] = '3,4'
      map_photos_returns Bounds.new(1, 3, 2, 4), photo, 'FFFF00', '?'
    end

    def map_photos_returns(bounds, photo, color, symbol)
      # TODO Dave move photo creation here
      stub(Photo).within { [ photo ] }
      controller.map_photos.should == {
        :partial => false,
        :bounds => bounds,
        :photos => [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => color,
            'symbol' => symbol
          }
        ]
      }
    end

    it "thins out excessively dense photos" do
      photo1 = Photo.make :id => 14,
        :latitude => PhotosController::INITIAL_MAP_BOUNDS.min_lat,
        :longitude => PhotosController::INITIAL_MAP_BOUNDS.min_long,
        :dateadded => 1.day.ago
      photo2 = Photo.make :id => 15,
        :latitude => PhotosController::INITIAL_MAP_BOUNDS.min_lat,
        :longitude => PhotosController::INITIAL_MAP_BOUNDS.min_long,
        :dateadded => 2.days.ago

      stub(Photo).within { [ photo1, photo2 ] }
      stub(controller).too_many { 0 }
      stub(controller).photos_per_bin { 1 }
      map_photos = controller.map_photos

      map_photos[:partial].should == true
      map_photos[:photos].map { |photo| photo['id'] }.should == [ 14 ]

    end

  end

  describe '#map_popup' do
    it "renders the partial" do
      photo = Photo.make :dateadded => Time.local(2011)
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => photo_path(photo) do |content|
        content.should have_selector 'img', :src => url_for_flickr_image(photo, 't')
      end
      response.should have_selector 'a', :href => person_path(photo.person), :content => photo.person.username
      response.should contain ', January 1, 2011.'
      response.should_not contain 'Guessed by'
      response.should_not contain 'Revealed'

    end

    it "displays guesses" do
      photo = Photo.make :person => Person.make(:id => 14), :dateadded => Time.local(2011)
      guess = Guess.make :photo => photo, :person => Person.make(:id => 15), :commented_at => Time.local(2011, 2)
      photo.guesses << guess
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

      response.should have_selector 'a', :href => person_path(guess.person), :content => guess.person.username
      response.should contain ', February 1, 2011.'
      response.should_not contain 'Revealed'

    end

    it "displays a revelation" do
      photo = Photo.make :person => Person.make(:id => 14), :dateadded => Time.local(2011)
      revelation = Revelation.make :photo => photo, :commented_at => Time.local(2011, 2)
      photo.revelation = revelation
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

      response.should_not contain 'Guessed by'
      response.should contain 'Revealed February 1, 2011.'

    end

  end

  describe '#unfound' do
    it 'renders the page' do
      photo = Photo.make
      stub(Photo).unfound_or_unconfirmed { [ photo ] }
      get :unfound

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => url_for_flickr_photo(photo), :content => 'Flickr'
      response.should have_selector 'a', :href => photo_path(photo), :content => 'GWW'
      response.should have_selector 'a', :href => person_path(photo.person), :content => 'poster_username'

    end
  end

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.utc(2011) }
      stub(Photo).unfound_or_unconfirmed { [ Photo.make ] }
      get :unfound_data

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'photos', :updated_at => '1293840000' do |content|
        content.should have_selector 'photo', :posted_by => 'poster_username'
      end

    end
  end

  describe '#show' do
    it 'renders the page' do
      photo = Photo.make :id => 1, :dateadded => Time.local(2010)
      guess = Guess.make :photo => photo
      photo.guesses << guess
      stub(Photo).includes.stub!.find(photo.id) { photo }
      stub(Comment).find_all_by_photo_id(photo) { [ Comment.make(:photo => photo) ] }
      get :show, :id => photo.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => url_for_flickr_photo(photo) do |content|
        content.should have_selector 'img', :src => url_for_flickr_image(photo)
      end
      response.should contain 'Added to the group at 12:00 AM, January 1, 2010'
      response.should contain 'This photo is unfound.'
      response.should have_selector 'table' do |content|
        content.should have_selector 'td', :content => 'guesser_username'
        content.should have_selector 'td', :content => 'guess text'
      end
      response.should have_selector 'strong', :content => 'commenter_username'
      response.should contain 'comment text'

    end
  end

end
