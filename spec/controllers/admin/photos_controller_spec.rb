require 'spec_helper'

describe Admin::PhotosController do
  integrate_views
  without_transactions

  describe '#update' do
    it 'does some work and redirects to the admin index' do
      mock_clear_page_cache 2
      mock(Photo).update_all_from_flickr { [ 1, 2, 3, 4 ] }
      get :update
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should ==
        'Created 1 new photos and 2 new users. Got 3 pages out of 4.'
    end
  end

  describe '#update_statistics' do
    it 'does some work and redirects to the admin index' do
      mock(Photo).update_statistics
      mock_clear_page_cache
      get :update_statistics
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics.'
    end
  end

  describe '#unfound' do
    it 'renders the page' do
      photo = Photo.make :id => 1
      stub(Photo).unfound_or_unconfirmed { [ photo ] }
      get :unfound
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '#inaccessible' do
    it 'renders the page' do
      photo = Photo.make :id => 1
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
      photo = Photo.make :id => 1
      stub(Photo).multipoint { [ photo ] }
      get :multipoint
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/admin/photos/edit/1]', :text => 'Edit'
    end
  end

  describe '#edit' do
    it 'renders the page without loading comments' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).find(photo.id.to_s, anything) { photo }
      #noinspection RubyResolve
      stub(Comment).find_all_by_photo_id(photo) { [ Comment.make :id => 222 ] }
      get :edit, :id => photo.id, :nocomment => 'true'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Added to the group at 12:00 AM, January 01, 2011/
      response.should have_text /This photo is unfound./
      response.should have_tag 'form[action=/admin/photos/change_game_status/111]', :text => /Change this photo's status from unfound to/ do
        with_tag 'input[value=unconfirmed]'
      end
      response.should have_tag 'form[action=/admin/photos/add_answer/111]' do
        with_tag 'input[type=submit][name=commit][value=Add this guess]'
        with_tag 'input[type=hidden][name=comment_id][value=222]'
      end

    end

    it 'loads comments and renders the page' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).find(photo.id.to_s, anything) { photo }
      stub(photo).load_comments { [ Comment.make :id => 222 ] }
      mock_clear_page_cache
      get :edit, :id => photo.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Added to the group at 12:00 AM, January 01, 2011/
      response.should have_text /This photo is unfound./
      response.should have_tag 'form[action=/admin/photos/change_game_status/111]', :text => /Change this photo's status from unfound to/ do
        with_tag 'input[value=unconfirmed]'
      end
      response.should have_tag 'form[action=/admin/photos/add_answer/111]' do
        with_tag 'input[type=submit][name=commit][value=Add this guess]'
        with_tag 'input[type=hidden][name=comment_id][value=222]'
      end

    end

  end

  describe '#change_game_status' do
    it 'changes the game status and reloads the page' do
      mock(Photo).change_game_status('1', 'unconfirmed')
      mock_clear_page_cache
      get :change_game_status, :id => 1, :commit => 'unconfirmed'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end
  end

  describe '#add_answer' do
    it "adds a selected answer" do
      mock(Comment).add_selected_answer '2', 'username'
      mock_clear_page_cache
      post :add_answer, :id => '1', :comment_id => '2', :username => 'username'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

    it "notifies the user if there was an error" do
      mock(Comment).add_selected_answer('2', 'username') { raise Comment::AddAnswerError, 'Sorry' }
      post :add_answer, :id => '1', :comment_id => '2', :username => 'username'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#add_entered_answer' do
    it "adds an entered answer" do
      mock(Comment).add_entered_answer 1, 'username', 'comment text'
      mock_clear_page_cache
      post :add_custom_answer, :id => '1', :person => { :username => 'username' }, :comment_text => 'comment text'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

    it "notifies the user if there was an error" do
      mock(Comment).add_entered_answer(1, 'username', 'comment text') { raise Comment::AddAnswerError, 'Sorry' }
      post :add_custom_answer, :id => '1', :person => { :username => 'username' }, :comment_text => 'comment text'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#remove_revelation' do
    it "removes a revelation" do
      mock(Comment).remove_revelation '2'
      mock_clear_page_cache
      post :remove_revelation, :id => '1', :comment_id => '2'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end
  end

  describe '#remove_guess' do
    it "removes a guess" do
      mock(Comment).remove_guess '2'
      mock_clear_page_cache
      post :remove_guess, :id => '1', :comment_id => '2'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end

    it "notifies the user if there was an error" do
      mock(Comment).remove_guess('2') { raise Comment::RemoveGuessError, 'Sorry' }
      post :remove_guess, :id => '1', :comment_id => '2'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#add_answer' do
    it "adds an answer" do
      mock(Comment).add_selected_answer '2', 'username'
      mock_clear_page_cache
      post :add_answer, :id => '1', :comment_id => '2', :username => 'username'
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1, :nocomment => 'true'
    end
  end

  describe '#reload_comments' do
    it 'just redirects to the edit page without the nocomment param' do
      get :reload_comments, :id => 1
      #noinspection RubyResolve
      response.should redirect_to edit_photo_path :id => 1
    end
  end

  describe '#destroy' do
    it 'destroys' do
      mock(Photo).destroy_photo_and_dependent_objects '1'
      mock_clear_page_cache
      get :destroy, :id => 1
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
    end
  end

  describe '#edit_in_gww' do
    it 'redirects to the given photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :edit_in_gww, :from => "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      #noinspection RubyResolve
      response.should redirect_to edit_photo_path photo

    end

    it 'punts an unknown photo Flickr ID' do
      #noinspection RubyResolve
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :edit_in_gww, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Sorry/

    end

    it 'punts unknown URLs' do
      get :edit_in_gww, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /Hmmm/

    end

  end

end
