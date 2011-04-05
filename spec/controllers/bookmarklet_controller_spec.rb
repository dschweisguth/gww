require 'spec_helper'

describe BookmarkletController do
  render_views

  describe '#show' do
    it 'redirects to the given photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :show, :from => "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to photo_path photo

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :show, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that photo/

    end

    it 'redirects to the given person' do
      person = Person.make
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, :from => "http://www.flickr.com/people/#{person.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to person_path person

    end

    it 'handles a person whose custom URL is the same as their username' do
      person = Person.make
      stub(Person).find_by_flickrid(person.username) { nil }
      stub(Person).find_by_username(person.username) { person }
      get :show, :from => "http://www.flickr.com/people/#{person.username}/"

      #noinspection RubyResolve
      response.should redirect_to person_path person

    end

    it 'punts an unknown person' do
      stub(Person).find_by_flickrid('person_flickrid') { nil }
      get :show, :from => "http://www.flickr.com/people/person_flickrid/"

      #noinspection RubyResolve
      response.should redirect_to root_path
      flash[:general_error].should =~ /Sorry, Guess Where Watcher doesn't know anything about that person/

    end

    it 'handles a /photo/ URL with a person Flickr ID but no photo Flickr ID' do
      person = Person.make
      stub(Person).find_by_flickrid(person.flickrid) { person }
      get :show, :from => "http://www.flickr.com/photos/#{person.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to person_path person

    end

    it 'punts unknown URLs' do
      get :show, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should redirect_to root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

end
