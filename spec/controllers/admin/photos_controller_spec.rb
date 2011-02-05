require 'spec_helper'

describe Admin::PhotosController do
  integrate_views

  describe '.update_statistics' do
    it 'does some work and redirects to the admin index' do
      mock(Photo).update_statistics
      any_instance_of(Admin::PhotosController) { |i| stub(i).expire_cached_pages }
      get :update_statistics
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics.</br>'
    end
  end

  describe '.unfound' do
    it 'renders the page' do
      photo = Photo.new_for_test :id => 1
      stub(photo).id { 1 }
      stub(Photo).unfound_or_unconfirmed { [ photo ] }
      get :unfound
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '.inaccessible' do
    it 'renders the page' do
      photo = Photo.new_for_test :id => 1
      stub(photo).id { 1 }
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.utc(2011) }
      stub(Photo).all { [ photo ] }
      get :inaccessible
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

end
