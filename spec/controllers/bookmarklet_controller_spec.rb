describe BookmarkletController do
  describe '#show' do
    it "redirects to the given photo" do
      photo = build_stubbed :photo, flickrid: '0123456789' # must be all digits like the real thing
      allow(Photo).to receive(:find_by_flickrid).with(photo.flickrid).and_return(photo)
      get :show, from: url_for_flickr_photo(photo)

      expect(response).to redirect_to photo_path photo

    end

    # Used in development
    it "handles http when redirecting to a photo" do
      photo = build_stubbed :photo, flickrid: '0123456789' # must be all digits like the real thing
      allow(Photo).to receive(:find_by_flickrid).with(photo.flickrid).and_return(photo)
      get :show, from: "http://www.flickr.com/photos/#{photo.person.identifier}/#{photo.flickrid}/"

      expect(response).to redirect_to photo_path photo

    end

    it "punts an unknown photo Flickr ID" do
      allow(Photo).to receive(:find_by_flickrid).with('0123456789').and_return(nil)
      get :show, from: 'https://www.flickr.com/photos/person_flickrid/0123456789/'

      expect(response).to redirect_to root_path
      expect(flash[:general_error]).to match(/Sorry, Guess Where Watcher doesn't know anything about that photo/)

    end

    it "redirects to the given person" do
      person = build_stubbed :person, pathalias: 'pathalias'
      allow(Person).to receive(:find_by_pathalias).with(person.pathalias).and_return(person)
      get :show, from: url_for_flickr_person(person)

      expect(response).to redirect_to person_path person

    end

    # Used in development
    it "handles http when redirecting to a person" do
      person = build_stubbed :person, pathalias: 'pathalias'
      allow(Person).to receive(:find_by_pathalias).with(person.pathalias).and_return(person)
      get :show, from: "http://www.flickr.com/people/#{person.identifier}/"

      expect(response).to redirect_to person_path person

    end

    it "handles a URL with a flickrid" do
      person = build_stubbed :person
      allow(Person).to receive(:find_by_pathalias).with(person.flickrid).and_return(nil)
      allow(Person).to receive(:find_by_flickrid).with(person.flickrid).and_return(person)
      get :show, from: "https://www.flickr.com/people/#{person.flickrid}/"

      expect(response).to redirect_to person_path person

    end

    it "punts an unknown person" do
      allow(Person).to receive(:find_by_pathalias).with('person_flickrid').and_return(nil)
      allow(Person).to receive(:find_by_flickrid).with('person_flickrid').and_return(nil)
      get :show, from: "https://www.flickr.com/people/person_flickrid/"

      expect(response).to redirect_to root_path
      expect(flash[:general_error]).to match(/Sorry, Guess Where Watcher doesn't know anything about that person/)

    end

    it "handles a /photo/ URL with a person Flickr ID but no photo Flickr ID" do
      person = build_stubbed :person
      allow(Person).to receive(:find_by_pathalias).with(person.flickrid).and_return(nil)
      allow(Person).to receive(:find_by_flickrid).with(person.flickrid).and_return(person)
      get :show, from: "https://www.flickr.com/photos/#{person.flickrid}/"

      expect(response).to redirect_to person_path person

    end

    it "punts unknown URLs" do
      get :show, from: 'https://www.notflickr.com/'

      expect(response).to redirect_to root_path
      expect(flash[:general_error]).to match(/Hmmm/)

    end

  end

end
