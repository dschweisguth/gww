require 'spec_helper'

describe BookmarkletController do
  render_views

  describe '#show' do
    it 'redirects to the given photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :show, :from => "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      response.should redirect_to photo_path photo

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :show, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that photo/

    end

    it 'redirects to the given person' do
      person = Person.make :pathalias => 'pathalias'
      stub(Person).find_by_pathalias(person.pathalias) { person }
      get :show, :from => "http://www.flickr.com/people/#{person.pathalias}/"

      response.should redirect_to person_path person

    end

    it "handles a URL with a flickrid" do
      person = Person.make
      stub(Person).find_by_pathalias(person.flickrid) { nil }
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, :from => "http://www.flickr.com/people/#{person.flickrid}/"

      response.should redirect_to person_path person

    end

    it 'punts an unknown person' do
      stub(Person).find_by_flickrid('person_flickrid') { nil }
      get :show, :from => "http://www.flickr.com/people/person_flickrid/"

      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that person/

    end

    it 'handles a /photo/ URL with a person Flickr ID but no photo Flickr ID' do
      person = Person.make
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, :from => "http://www.flickr.com/photos/#{person.flickrid}/"

      response.should redirect_to person_path person

    end

    it 'punts unknown URLs' do
      get :show, :from => 'http://www.notflickr.com/'

      response.should redirect_to root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

end
