require 'spec_helper'

describe Admin::PhotosController do
  integrate_views

  describe '#update_statistics' do
    it 'does some work and redirects to the admin index' do
      mock(Photo).update_statistics
      stub_expire_cached_pages
      get :update_statistics
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics.</br>'
    end
  end

  describe '#unfound' do
    it 'renders the page' do
      photo = Photo.make
      stub(photo).id { 1 }
      stub(Photo).unfound_or_unconfirmed { [ photo ] }
      get :unfound
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '#inaccessible' do
    it 'renders the page' do
      photo = Photo.make
      stub(photo).id { 1 }
      stub(FlickrUpdate).latest { FlickrUpdate.make :created_at => Time.utc(2011) }
      stub(Photo).all { [ photo ] }
      get :inaccessible
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '#multipoint' do
    it 'renders the page' do
      photo = Photo.make
      stub(photo).id { 1 }
      stub(Photo).multipoint { [ photo ] }
      get :multipoint
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '#edit' do
    it 'renders the page without loading comments' do
      photo = Photo.make :dateadded => Time.local(2011)
      stub(photo).id { 1 }
      stub(Photo).find(photo.id.to_s, anything) { photo }
      #noinspection RubyResolve
      mock(Comment).find_all_by_photo_id(photo) { [ Comment.make ] }
      get :edit, :id => photo.id, :nocomment => 'true'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Added to the group at 12:00 AM, January 01, 2011/
      response.should have_text /This photo is unfound./
      response.should have_tag 'form[action=/admin/photos/change_game_status/1]', :text => /Change this photo's status from unfound to/ do
        with_tag 'input[value=unconfirmed]'
      end
      response.should have_tag 'form[action=/admin/photos/update_answer/1]' do
        with_tag 'strong', :text => 'comment_username says:'
      end

    end

    it 'loads comments and renders the page' do
      photo = Photo.make :dateadded => Time.local(2011)
      stub(photo).id { 1 }
      stub(Photo).find(photo.id.to_s, anything) { photo }
      stub(photo).load_comments { [ Comment.make ] }
      stub_expire_cached_pages
      get :edit, :id => photo.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Added to the group at 12:00 AM, January 01, 2011/
      response.should have_text /This photo is unfound./
      response.should have_tag 'form[action=/admin/photos/change_game_status/1]', :text => /Change this photo's status from unfound to/ do
        with_tag 'input[value=unconfirmed]'
      end
      response.should have_tag 'form[action=/admin/photos/update_answer/1]' do
        with_tag 'strong', :text => 'comment_username says:'
      end

    end

  end

  describe '#change_game_status' do
    it 'changes the game status and reloads the page' do
      mock(Photo).change_game_status('1', 'unconfirmed')
      stub_expire_cached_pages
      get :change_game_status, :id => 1, :commit => 'unconfirmed'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end
  end

  describe '.update_answer' do
    it 'adds a guess or revelation' do
      mock(Photo).add_answer 2, ''
      stub_expire_cached_pages
      get :update_answer, :id => '1', :comment => { :id => 2 }, :person => { :username => '' },
        :commit => 'Add this guess or revelation'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

    it 'removes a guess or revelation' do
      mock(Photo).remove_answer '1', 2
      stub_expire_cached_pages
      get :update_answer, :id => '1', :comment => { :id => 2 }, :person => { :username => '' },
        :commit => 'Remove this guess or revelation'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

    it 'complains if the user removes a guess or revelation incorrectly' do
      mock(Photo).remove_answer('1', 2) { raise Photo::RemoveAnswerError, 'the message' }
      stub_expire_cached_pages
      get :update_answer, :id => '1', :comment => { :id => 2 }, :person => { :username => '' },
        :commit => 'Remove this guess or revelation'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
      flash[:notice].should == 'the message'
    end

    it 'punts if the user tries to add an answer without choosing a comment' do
      get :update_answer, :id => '1', :person => { :username => '' },
        :commit => 'Add this guess or revelation'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

  end

  def stub_expire_cached_pages
    any_instance_of(Admin::PhotosController) { |i| stub(i).expire_cached_pages }
  end

end
