require 'spec_helper'

describe BookmarkletController do
  integrate_views

  describe '#view' do
    it 'redirects to the given photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :view, :from => "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

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

    it 'handles a person whose custom URL is the same as their username' do
      person = Person.make
      #noinspection RubyResolve
      stub(Person).find_by_flickrid(person.username) { nil }
      #noinspection RubyResolve
      stub(Person).find_by_username(person.username) { person }
      get :view, :from => "http://www.flickr.com/people/#{person.username}/"

      #noinspection RubyResolve
      response.should redirect_to show_person_path person

    end

    it 'punts an unknown person' do
      #noinspection RubyResolve
      stub(Person).find_by_flickrid('person_flickrid') { nil }
      get :view, :from => "http://www.flickr.com/people/person_flickrid/"

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Sorry, Guess Where Watcher doesn't know anything about that person/

    end

    it 'handles a /photo/ URL with a person Flickr ID but no photo Flickr ID' do
      person = Person.make
      #noinspection RubyResolve
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :view, :from => "http://www.flickr.com/photos/#{person.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to show_person_path person

    end

    it 'punts unknown URLs' do
      get :view, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Hmmm/

    end

  end

end
