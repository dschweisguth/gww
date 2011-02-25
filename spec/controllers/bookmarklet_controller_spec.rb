require 'spec_helper'

describe BookmarkletController do
  integrate_views

  describe '#view' do
    it 'redirects to the given photo' do
      photo = Photo.make
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid('0123456789') { photo }
      get :view, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should redirect_to show_photo_path :id => photo

    end

    it 'punts an unknown photo Flickr ID' do
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :view, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Sorry, Guess Where Watcher doesn't know anything about that photo/

    end

    it 'redirects to the given person' do
      person = Person.make
      #noinspection RubyResolve
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :view, :from => "http://www.flickr.com/people/#{person.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to show_person_path person

    end

    it 'punts an unknown person Flickr ID' do
      #noinspection RubyResolve
      stub(Person).find_by_flickrid('person_flickrid') { nil }
      get :view, :from => "http://www.flickr.com/people/person_flickrid/"

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Sorry, Guess Where Watcher doesn't know anything about that person/

    end

    it 'punts unknown URLs' do
      get :view, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Hmmm/

    end

  end

end
