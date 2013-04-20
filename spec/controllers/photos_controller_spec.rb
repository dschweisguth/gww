require 'spec_helper'

describe PhotosController do
  render_views

  describe '#index' do
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

      response.should be_success
      response.should contain /GWW\.config = #{Regexp.escape assigns[:json]};/

    end
  end

  describe '#map_json' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(controller).map_photos { json }
      get :map_json

      response.should be_success
      response.body.should == json.to_json

    end
  end

  describe '#map_photos' do
    before do
      @initial_bounds = PhotosController::INITIAL_MAP_BOUNDS
      @default_max_photos = controller.max_map_photos
    end

    it "returns an unfound photo" do
      returns @initial_bounds
    end

    it "copies an inferred geocode to the stated one" do
      photo = Photo.make :id => 1, :inferred_latitude => 37, :inferred_longitude => -122
      stub(Photo).mapped(@initial_bounds, @default_max_photos + 1) { [ photo ] }
      stub(Photo).oldest { Photo.make :dateadded => 1.day.ago }
      controller.map_photos.should == {
        :partial => false,
        :bounds => @initial_bounds,
        :photos => [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => 'FFFF00',
            'symbol' => '?'
          }
        ]
      }
    end

    it "echos non-default bounds" do
      controller.params[:sw] = '1,2'
      controller.params[:ne] = '3,4'
      returns Bounds.new(1, 3, 2, 4)
    end

    def returns(bounds)
      photo = Photo.make :id => 1, :latitude => 37, :longitude => -122
      stub(Photo).mapped(bounds, @default_max_photos + 1) { [ photo ] }
      stub(Photo).oldest { Photo.make :dateadded => 1.day.ago }
      controller.map_photos.should == {
        :partial => false,
        :bounds => bounds,
        :photos => [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => 'FFFF00',
            'symbol' => '?'
          }
        ]
      }
    end

    it "returns no more than a maximum number of photos" do
      stub(controller).max_map_photos { 1 }
      photo = Photo.make :id => 1, :latitude => 37, :longitude => -122
      oldest_photo = Photo.make :dateadded => 1.day.ago
      stub(Photo).mapped(@initial_bounds, 2) { [ photo, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      controller.map_photos.should == {
        :partial => true,
        :bounds => @initial_bounds,
        :photos => [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => 'FFFF00',
            'symbol' => '?'
          }
        ]
      }
    end

    it "handles no photos" do
      stub(Photo).mapped(@initial_bounds, @default_max_photos + 1) { [] }
      stub(Photo).oldest { nil }
      controller.map_photos.should == {
        :partial => false,
        :bounds => @initial_bounds,
        :photos => []
      }
    end

  end

  describe '#map_popup' do
    it "renders the partial" do
      photo = Photo.make :dateadded => Time.local(2011)
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

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

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.utc(2011) }
      stub(Photo).unfound_or_unconfirmed { [ Photo.make ] }
      get :unfound_data

      response.should be_success
      response.should have_selector 'photos', :updated_at => '1293840000' do |content|
        content.should have_selector 'photo', :posted_by => 'poster_username'
      end

    end
  end

  describe '#show' do
    it "renders the page" do
      photo = Photo.make :id => 1, :dateadded => Time.local(2010), :other_user_comments => 11, :views => 22, :faves => 33
      guess = Guess.make :photo => photo
      photo.guesses << guess
      stub(Photo).find(photo.id) { photo }
      stub(Comment).find_all_by_photo_id(photo) { [ Comment.make(:photo => photo) ] }
      get :show, :id => photo.id

      response.should be_success
      response.should have_selector 'a', :href => url_for_flickr_photo_in_pool(photo) do |content|
        content.should have_selector 'img', :src => url_for_flickr_image(photo, 'z')
      end
      response.should contain 'This photo is unfound.'
      response.should have_selector 'table' do |content|
        content.should have_selector 'td', :content => 'guesser_username'
        content.should have_selector 'td', :content => 'guess text'
      end
      response.should have_selector 'strong', :content => 'commenter_username'
      response.should contain 'comment text'
      response.should contain 'This photo was added to the group at 12:00 AM, January 1, 2010.'
      response.should contain "This photo hasn't been found or revealed yet"
      response.should_not contain 'It was mapped by the photographer'
      response.should_not contain 'It was auto-mapped'
      response.should contain '11 comments'
      response.should contain '22 views'
      response.should contain '33 faves'
      response.should_not contain 'GWW.config'

    end

    it "includes a map if the photo is mapped" do
      photo = Photo.make(:id => 1, :latitude => 37, :longitude => -122, :accuracy => 12)
      stub(Photo).find(photo.id) { photo }
      oldest = Photo.make :dateadded => 1.day.ago
      stub(Photo).oldest { oldest }
      get :show, :id => photo.id

      json = {
        'id' => photo.id,
        'latitude' => photo.latitude.to_s,
        'longitude' => photo.longitude.to_s,
        'color' => 'FFFF00',
        'symbol' => '?'
      }
      ActiveSupport::JSON.decode(assigns[:json]) == json

      response.should be_success
      response.should contain 'It was mapped by the photographer'
      response.should_not contain "This photo hasn't been found or revealed yet"
      response.should_not contain 'It was auto-mapped'
      response.should have_selector '#map'
      response.should contain /GWW\.config = #{Regexp.escape assigns[:json]};/

    end

    it "includes a map if the photo is auto-mapped" do
      photo = Photo.make(:id => 1, :inferred_latitude => 37, :inferred_longitude => -122)
      stub(Photo).find(photo.id) { photo }
      oldest = Photo.make :dateadded => 1.day.ago
      stub(Photo).oldest { oldest }
      get :show, :id => photo.id

      json = {
        'id' => photo.id,
        'latitude' => photo.inferred_latitude.to_s,
        'longitude' => photo.inferred_longitude.to_s,
        'color' => 'FFFF00',
        'symbol' => '?'
      }
      ActiveSupport::JSON.decode(assigns[:json]).should == json

      response.should be_success
      response.should contain 'It was auto-mapped'
      response.should_not contain "This photo hasn't been found or revealed yet"
      response.should_not contain 'It was mapped by the photographer'
      response.should have_selector '#map'
      response.should contain /GWW\.config = #{Regexp.escape assigns[:json]};/

    end

    def includes_a_map(photo)
      stub(Photo).includes.stub!.find(photo.id) { photo }
      oldest = Photo.make :dateadded => 1.day.ago
      stub(Photo).oldest { oldest }
      get :show, :id => photo.id

      json = {
        'color' => 'FFFF00',
        'id' => photo.id,
        'latitude' => photo.latitude,
        'longitude' => photo.longitude,
        'symbol' => '?'
      }.to_json
      assigns[:json].should == json

      response.should be_success
      response.should have_selector '#map'
      response.should contain /GWW\.config = #{Regexp.escape json};/

    end

  end

end
