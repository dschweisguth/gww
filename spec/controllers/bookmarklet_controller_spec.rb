describe BookmarkletController do
  render_views

  describe '#show' do
    # This test is probably obsolete, in that Flickr seems to always use https now. But leave it in for a while just in case.
    it 'redirects to the given photo' do
      photo = build_stubbed :photo, flickrid: '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :show, from: url_for_flickr_photo(photo)

      response.should redirect_to photo_path photo

    end

    it 'handles https when redirecting to a photo' do
      photo = build_stubbed :photo, flickrid: '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :show, from: url_for_flickr_photo(photo)

      response.should redirect_to photo_path photo

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :show, from: 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that photo/

    end

    # This test is probably obsolete, in that Flickr seems to always use https now. But leave it in for a while just in case.
    it 'redirects to the given person' do
      person = build_stubbed :person, pathalias: 'pathalias'
      stub(Person).find_by_pathalias(person.pathalias) { person }
      get :show, from: url_for_flickr_person(person)

      response.should redirect_to person_path person

    end

    it 'handles https when redirecting to a person' do
      person = build_stubbed :person, pathalias: 'pathalias'
      stub(Person).find_by_pathalias(person.pathalias) { person }
      get :show, from: url_for_flickr_person(person)

      response.should redirect_to person_path person

    end

    it "handles a URL with a flickrid" do
      person = build_stubbed :person
      stub(Person).find_by_pathalias(person.flickrid) { nil }
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, from: "https://www.flickr.com/people/#{person.flickrid}/"

      response.should redirect_to person_path person

    end

    it 'punts an unknown person' do
      stub(Person).find_by_pathalias('person_flickrid') { nil }
      stub(Person).find_by_flickrid('person_flickrid') { nil }
      get :show, from: "https://www.flickr.com/people/person_flickrid/"

      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that person/

    end

    it 'handles a /photo/ URL with a person Flickr ID but no photo Flickr ID' do
      person = build_stubbed :person
      stub(Person).find_by_pathalias(person.flickrid) { nil }
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, from: "https://www.flickr.com/photos/#{person.flickrid}/"

      response.should redirect_to person_path person

    end

    it 'punts unknown URLs' do
      get :show, from: 'http://www.notflickr.com/'

      response.should redirect_to root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

end
