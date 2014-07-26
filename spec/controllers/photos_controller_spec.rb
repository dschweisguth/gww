describe PhotosController do
  render_views

  describe '#index' do
    it 'renders the page' do
      sorted_by_param = 'username'
      order_param = '+'
      page_param = '1'

      # Mock methods from will_paginate's version of Array
      photo = build_stubbed :photo
      paginated_photos = [ photo ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(paginated_photos).total_entries { 1 }
      stub(Photo).all_sorted_and_paginated(sorted_by_param, order_param, page_param, 30) { paginated_photos }
      get :index, sorted_by: sorted_by_param, order: order_param, page: page_param

      response.should be_success
      response.body.should have_css 'h1', text: '1 photos'
      response.body.should have_link 'posted by', href: photos_path('username', '-', 1)
      response.body.should have_link photo.person.username, href: person_path(photo.person)

    end
  end

  describe '#map' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(Photo).all_for_map(PhotosController::INITIAL_MAP_BOUNDS, PhotosController::MAX_MAP_PHOTOS) { json }
      get :map

      assigns[:json].should == json.to_json

      response.should be_success
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

    end
  end

  describe '#map_json' do
    it "renders the page" do
      json = { 'property' => 'value' }
      stub(Photo).all_for_map(PhotosController::INITIAL_MAP_BOUNDS, PhotosController::MAX_MAP_PHOTOS) { json }
      get :map_json

      response.should be_success
      response.body.should == json.to_json

    end

    it "supports arbitrary bounds" do
      stub(Photo).all_for_map(Bounds.new(0, 1, 10, 11), PhotosController::MAX_MAP_PHOTOS) { { 'property' => 'value' } }
      get :map_json, sw: '0,10', ne: '1,11'
    end

  end

  describe '#map_popup' do
    it "renders the partial" do
      photo = build_stubbed :photo, dateadded: Time.local(2011)
      stub(photo).guesses { [] }
      stub(photo).revelation { nil }
      stub(Photo).find_with_associations(photo.id) { photo }
      get :map_popup, id: photo.id

      response.should be_success
      link = top_node.find %Q(a[href="#{photo_path(photo)}"])
      link.should have_css %Q(img[src="#{url_for_flickr_image(photo, 't')}"])
      response.body.should have_link photo.person.username, href: person_path(photo.person)
      response.body.should include ', January  1, 2011.'
      response.body.should_not include 'Guessed by'
      response.body.should_not include 'Revealed'

    end

    it "displays guesses" do
      photo = build_stubbed :photo, dateadded: Time.local(2011)
      guess = build_stubbed :guess, photo: photo, commented_at: Time.local(2011, 2)
      stub(photo).guesses { [guess] }
      stub(photo).revelation { nil }
      stub(Photo).find_with_associations(photo.id) { photo }
      get :map_popup, id: photo.id

      response.body.should have_link guess.person.username, href: person_path(guess.person)
      response.body.should include ', February  1, 2011.'
      response.body.should_not include 'Revealed'

    end

    it "displays a revelation" do
      photo = build_stubbed :photo, dateadded: Time.local(2011)
      stub(photo).guesses { [] }
      stub(photo).revelation { build_stubbed :revelation, photo: photo, commented_at: Time.local(2011, 2) }
      stub(Photo).find_with_associations(photo.id) { photo }
      get :map_popup, id: photo.id

      response.body.should_not include 'Guessed by'
      response.body.should include 'Revealed February  1, 2011.'

    end

  end

  describe '#unfound_data' do
    it 'renders the page' do
      stub(FlickrUpdate).latest { build_stubbed :flickr_update, created_at: Time.utc(2011) }
      photo = build_stubbed :photo
      stub(Photo).unfound_or_unconfirmed { [ photo ] }
      get :unfound_data

      response.should be_success
      photos = top_node.find 'photos[updated_at="1293840000"]'
      photos.should have_css "photo[posted_by=#{photo.person.username}]"

    end
  end

  describe '#search' do
    it "doesn't suppress an ArgumentError other than 'invalid date'" do
      stub(Date).parse { raise ArgumentError, "dated validation" }
      lambda { get :search, terms: 'from-date/1-1-2014/to-date/1-2-2014' }.should raise_error(ArgumentError, "dated validation")
    end
  end

  describe '#show' do
    it "renders the page" do
      photo = build_stubbed :photo, dateadded: Time.local(2010), other_user_comments: 11, views: 22, faves: 33
      guess = build_stubbed :guess, photo: photo
      stub(photo).guesses { [guess] }
      stub(Photo).find(photo.id) { photo }
      comment = build_stubbed :comment, photo: photo
      stub(photo).comments { [comment] }
      stub(photo).human_tags { [] }
      stub(photo).machine_tags { [] }
      get :show, id: photo.id

      response.should be_success
      link = top_node.find %Q(a[href="#{url_for_flickr_photo_in_pool(photo)}"])
      link.should have_css %Q(img[src="#{url_for_flickr_image(photo, 'z')}"])
      response.body.should include photo.title
      response.body.should include photo.description
      response.body.should include 'This photo is unfound.'
      table = top_node.find 'table'
      table.should have_css 'td', text: guess.person.username
      table.should have_css 'td', text: guess.comment_text
      response.body.should have_css 'strong', text: comment.username
      response.body.should include comment.comment_text
      response.body.should include 'This photo was added to the group at 12:00 AM, January  1, 2010.'
      response.body.should include "This photo hasn't been found or revealed yet"
      response.body.should_not include 'It was mapped by the photographer'
      response.body.should_not include 'It was auto-mapped'
      response.body.should include '11 comments'
      response.body.should include '22 views'
      response.body.should include '33 faves'
      response.body.should_not include 'GWW.config'
      response.body.should_not include 'Tags'
      response.body.should_not include 'Machine tags'

    end

    it "includes a map if the photo is mapped" do
      photo = build_stubbed :photo, latitude: 37, longitude: -122, accuracy: 12
      stub(photo).comments { [] }
      stub(photo).guesses { [] }
      stub(photo).revelation { nil }
      stub(photo).human_tags { [] }
      stub(photo).machine_tags { [] }
      stub(Photo).find(photo.id) { photo }
      oldest = build_stubbed :photo, dateadded: 1.day.ago
      stub(Photo).oldest { oldest }
      get :show, id: photo.id

      json = {
        'id' => photo.id,
        'latitude' => photo.latitude.to_s,
        'longitude' => photo.longitude.to_s,
        'color' => 'FFFF00',
        'symbol' => '?'
      }
      ActiveSupport::JSON.decode(assigns[:json]).should == json

      response.should be_success
      response.body.should include 'It was mapped by the photographer'
      response.body.should_not include "This photo hasn't been found or revealed yet"
      response.body.should_not include 'It was auto-mapped'
      response.body.should have_css '#map'
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

    end

    it "includes a map if the photo is auto-mapped" do
      photo = build_stubbed :photo, inferred_latitude: 37, inferred_longitude: -122
      stub(photo).comments { [] }
      stub(photo).guesses { [] }
      stub(photo).revelation { nil }
      stub(photo).human_tags { [] }
      stub(photo).machine_tags { [] }
      stub(Photo).find(photo.id) { photo }
      oldest = build_stubbed :photo, dateadded: 1.day.ago
      stub(Photo).oldest { oldest }
      get :show, id: photo.id

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
      response.body.should have_css '#map'
      response.body.should =~ /GWW\.config = #{Regexp.escape assigns[:json]};/

    end

    it "displays tags" do
      photo = build_stubbed :photo
      stub(photo).comments { [] }
      stub(photo).guesses { [] }
      stub(photo).revelation { nil }
      stub(photo).human_tags { [
        build_stubbed(:tag, raw: 'Tag 2'),
        build_stubbed(:tag, raw: 'Tag 1'),
      ] }
      stub(photo).machine_tags { [
        build_stubbed(:tag, raw: 'Machine tag 2'),
        build_stubbed(:tag, raw: 'Machine tag 1')
      ] }
      stub(Photo).find(photo.id) { photo }
      get :show, id: photo.id

      response.body.should =~ /Tags.*Tag 2.*Tag 1/m
      response.body.should =~ /Machine tags.*Machine tag 2.*Machine tag 1/m

    end

    it "styles a foundinSF or unfoundinSF tag differently if it doesn't match the photo" do
      photo = build_stubbed :photo
      stub(photo).comments { [] }
      stub(photo).guesses { [] }
      stub(photo).revelation { nil }
      stub(photo).human_tags { [build_stubbed(:tag, raw: 'foundinSF')] }
      stub(photo).machine_tags { [] }
      stub(Photo).find(photo.id) { photo }
      get :show, id: photo.id

      response.body.should have_css 'li.incorrect'

    end

  end

end
