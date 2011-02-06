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
      photo = Photo.new_for_test
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
      photo = Photo.new_for_test
      stub(photo).id { 1 }
      stub(FlickrUpdate).latest { FlickrUpdate.new_for_test :created_at => Time.utc(2011) }
      stub(Photo).all { [ photo ] }
      get :inaccessible
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '.multipoint' do
    it 'renders the page' do
      photo = Photo.new_for_test
      stub(photo).id { 1 }
      stub(Photo).multipoint { [ photo ] }
      get :multipoint
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '.edit' do
    it 'renders the page without loading comments' do
      photo = Photo.new_for_test :dateadded => Time.local(2011)
      stub(photo).id { 1 }
      stub(Photo).find(photo.id.to_s, anything) { photo }
      #noinspection RubyResolve
      mock(Comment).find_all_by_photo_id(photo) { [ Comment.new_for_test ] }
      get :edit, :id => photo.id, :nocomment => ''

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Added to the group at 12:00 AM, January 01, 2011/
      response.should have_text /This photo is unfound./
      response.should have_tag 'form[action=/admin/photos/change_game_status/1]', :text => /Change this photo's status from unfound to/ do
        with_tag 'input[value=unconfirmed]'
      end
      response.should have_tag 'form[action=/admin/photos/add_guess/1]' do
        with_tag 'strong', :text => 'comment_username says:'
      end

    end
  end

end
