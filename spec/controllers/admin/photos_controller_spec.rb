require 'spec_helper'

describe Admin::PhotosController do
  render_views

  describe '#update_all_from_flickr' do
    it 'does some work and redirects' do
      mock_clear_page_cache 2
      mock(Photo).update_all_from_flickr { [ 1, 2, 3, 4 ] }
      get :update_all_from_flickr
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should ==
        'Created 1 new photos and 2 new users. Got 3 pages out of 4.'
    end
  end

  describe '#update_statistics' do
    it 'does some work and redirects' do
      mock(Photo).update_statistics
      mock_clear_page_cache
      get :update_statistics
      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:notice].should == 'Updated statistics.'
    end
  end

  describe 'collections' do
    before do
      @photo = Photo.make :id => 1
    end

    describe '#unfound' do
      it 'renders the page' do
        stub(Photo).unfound_or_unconfirmed { [ @photo ] }
        get :unfound
        lists_photo
      end
    end

    describe '#inaccessible' do
      it 'renders the page' do
        stub(Photo).inaccessible { [ @photo ] }
        get :inaccessible
        lists_photo
      end
    end

    describe '#multipoint' do
      it 'renders the page' do
        stub(Photo).multipoint { [ @photo ] }
        get :multipoint
        lists_photo
      end
    end

    def lists_photo
      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :href => person_path(@photo.person), :content => @photo.person.username
      response.should have_selector 'td', :content => 'false'
      response.should have_selector 'td', :content => 'unfound'
      response.should have_selector 'a', :href => edit_admin_photo_path(@photo, :load_comments => true), :content => 'Edit'
    end

  end

  describe '#edit' do
    it 'renders the page without loading comments' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).includes.stub!.find(photo.id.to_s) { photo }
      stub(Comment).find_all_by_photo_id(photo) { [ Comment.make(:id => 222) ] }
      get :edit, :id => photo.id.to_s
      renders_edit_page
    end

    it 'loads comments and renders the page' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).includes.stub!.find(photo.id.to_s) { photo }
      stub(photo).load_comments { [ Comment.make(:id => 222) ] }
      mock_clear_page_cache
      get :edit, :id => photo.id.to_s, :load_comments => true
      renders_edit_page
    end

    def renders_edit_page
      #noinspection RubyResolve
      response.should be_success
      response.should contain 'Added to the group at 12:00 AM, January 1, 2011'
      response.should contain 'This photo is unfound.'
      response.should have_selector 'form', :action => change_game_status_path(111), :content => "Change this photo's status from unfound to" do |form|
        form.should have_selector 'input', :value => 'unconfirmed'
      end
      response.should have_selector 'form', :action => add_selected_answer_path(111) do |form|
        form.should have_selector 'input', :type => 'submit', :name => 'commit', :value => 'Add this guess'
        form.should have_selector 'input', :type => 'hidden', :name => 'comment_id', :value => '222'
      end
    end

  end

  describe '#change_game_status' do
    it 'changes the game status and reloads the page' do
      mock(Photo).change_game_status('1', 'unconfirmed')
      mock_clear_page_cache
      get :change_game_status, :id => '1', :commit => 'unconfirmed'
      redirects_to_edit_path 1
    end
  end

  describe '#add_selected_answer' do
    it "adds a selected answer" do
      mock(Comment).add_selected_answer '2', 'username'
      mock_clear_page_cache
      post :add_selected_answer, :id => '1', :comment_id => '2', :username => 'username'
      redirects_to_edit_path 1
    end

    it "notifies the user if there was an error" do
      mock(Comment).add_selected_answer('2', 'username') { raise Comment::AddAnswerError, 'Sorry' }
      post :add_selected_answer, :id => '1', :comment_id => '2', :username => 'username'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#add_entered_answer' do
    it "adds an entered answer" do
      mock(Comment).add_entered_answer 1, 'username', 'answer text'
      mock_clear_page_cache
      post :add_entered_answer, :id => '1', :username => 'username', :answer_text => 'answer text'
      redirects_to_edit_path 1
    end

    it "notifies the user if there was an error" do
      mock(Comment).add_entered_answer(1, 'username', 'answer text') { raise Comment::AddAnswerError, 'Sorry' }
      post :add_entered_answer, :id => '1', :username => 'username', :answer_text => 'answer text'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#remove_revelation' do
    it "removes a revelation" do
      mock(Comment).remove_revelation '2'
      mock_clear_page_cache
      post :remove_revelation, :id => '1', :comment_id => '2'
      redirects_to_edit_path 1
    end
  end

  describe '#remove_guess' do
    it "removes a guess" do
      mock(Comment).remove_guess '2'
      mock_clear_page_cache
      post :remove_guess, :id => '1', :comment_id => '2'
      redirects_to_edit_path 1
    end

    it "notifies the user if there was an error" do
      mock(Comment).remove_guess('2') { raise Comment::RemoveGuessError, 'Sorry' }
      post :remove_guess, :id => '1', :comment_id => '2'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#reload_comments' do
    it 'just redirects to the edit page with load_comments=true' do
      get :reload_comments, :id => '1'
      redirects_to_edit_path 1, :load_comments => true
    end
  end

  describe '#destroy' do
    it 'destroys' do
      mock(Photo).destroy_photo_and_dependent_objects '1'
      mock_clear_page_cache
      get :destroy, :id => '1'
      response.should redirect_to admin_root_path
    end
  end

  describe '#edit_in_gww' do
    it 'redirects to the given photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :edit_in_gww, :from => "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      redirects_to_edit_path photo, :load_comments => true

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :edit_in_gww, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Sorry/

    end

    it 'punts unknown URLs' do
      get :edit_in_gww, :from => 'http://www.notflickr.com/'

      #noinspection RubyResolve
      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

  def redirects_to_edit_path(photo_or_id, options = {})
    #noinspection RubyResolve
    response.should redirect_to edit_admin_photo_path photo_or_id, options
  end

end
