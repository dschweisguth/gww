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
      response.body.should have_selector 'h1', :text => '1 photos'
      response.body.should have_link 'posted by', :href => photos_path('username', '-', 1)
      response.body.should have_link 'poster_username', :href => person_path(photo.person)

    end
  end

  describe '#map' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(controller).map_photos { json }
      get :map

      assigns[:json].should == json.to_json

      response.should be_success
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

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
      link = top_node.find %Q(a[href="#{photo_path(photo)}"])
      link.should have_selector %Q(img[src="#{url_for_flickr_image(photo, 't')}"])
      response.body.should have_link photo.person.username, :href => person_path(photo.person)
      response.body.should include ', January  1, 2011.'
      response.body.should_not include 'Guessed by'
      response.body.should_not include 'Revealed'

    end

    it "displays guesses" do
      photo = Photo.make :person => Person.make(:id => 14), :dateadded => Time.local(2011)
      guess = Guess.make :photo => photo, :person => Person.make(:id => 15), :commented_at => Time.local(2011, 2)
      photo.guesses << guess
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

      response.body.should have_link guess.person.username, :href => person_path(guess.person)
      response.body.should include ', February  1, 2011.'
      response.body.should_not include 'Revealed'

    end

    it "displays a revelation" do
      photo = Photo.make :person => Person.make(:id => 14), :dateadded => Time.local(2011)
      revelation = Revelation.make :photo => photo, :commented_at => Time.local(2011, 2)
      photo.revelation = revelation
      stub(Photo).includes.stub!.find(photo.id) { photo }
      get :map_popup, :id => photo.id

      response.body.should_not include 'Guessed by'
      response.body.should include 'Revealed February  1, 2011.'

    end

  end

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.utc(2011) }
      stub(Photo).unfound_or_unconfirmed { [ Photo.make ] }
      get :unfound_data

      response.should be_success
      photos = top_node.find 'photos[updated_at="1293840000"]'
      photos.should have_selector 'photo[posted_by=poster_username]'

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
      link = top_node.find %Q(a[href="#{url_for_flickr_photo_in_pool(photo)}"])
      link.should have_selector %Q(img[src="#{url_for_flickr_image(photo, 'z')}"])
      response.body.should include 'This photo is unfound.'
      table = top_node.find 'table'
      table.should have_selector 'td', :text => 'guesser_username'
      table.should have_selector 'td', :text => 'guess text'
      response.body.should have_selector 'strong', :text => 'commenter_username'
      response.body.should include 'comment text'
      response.body.should include 'This photo was added to the group at 12:00 AM, January  1, 2010.'
      response.body.should include "This photo hasn't been found or revealed yet"
      response.body.should_not include 'It was mapped by the photographer'
      response.body.should_not include 'It was auto-mapped'
      response.body.should include '11 comments'
      response.body.should include '22 views'
      response.body.should include '33 faves'
      response.body.should_not include 'GWW.config'

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
      response.body.should include 'It was mapped by the photographer'
      response.body.should_not include "This photo hasn't been found or revealed yet"
      response.body.should_not include 'It was auto-mapped'
      response.body.should have_selector '#map'
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

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
      response.body.should include 'It was auto-mapped'
      response.body.should_not include "This photo hasn't been found or revealed yet"
      response.body.should_not include 'It was mapped by the photographer'
      response.body.should have_selector '#map'
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

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
      response.body.should have_selector '#map'
      response.body.should =~ /GWW\.config = #{Regexp.escape json};/

    end

  end

end
