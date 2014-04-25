require 'spec_helper'

describe Admin::PhotosController do
  render_views

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
      response.should be_success
      response.body.should have_link @photo.person.username, :href => person_path(@photo.person)
      response.body.should have_css 'td', :text => 'false'
      response.body.should have_css 'td', :text => 'unfound'
      response.body.should have_link 'Edit', :href => edit_admin_photo_path(@photo, :update_from_flickr => true)
    end

  end

  describe '#edit' do
    it 'renders the page without loading comments' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).find_with_associations(photo.id) { photo }
      stub(photo).comments { [ Comment.make(:id => 222) ] }
      get :edit, :id => photo.id
      renders_edit_page
    end

    it 'loads comments and renders the page' do
      photo = Photo.make :id => 111, :dateadded => Time.local(2011)
      stub(Photo).find_with_associations(photo.id) { photo }
      stub(photo).update_from_flickr
      stub(photo).comments { [ Comment.make(:id => 222) ] }
      mock_clear_page_cache
      get :edit, :id => photo.id, :update_from_flickr => true
      renders_edit_page
    end

    def renders_edit_page
      response.should be_success
      response.body.should include 'This photo is unfound.'

      unconfirmed_form = top_node.find %Q(form[action="#{change_game_status_path(111)}"]), :text => "Change this photo's status from unfound to"
      unconfirmed_form.should have_css 'input[name=commit][value=unconfirmed]'

      comments_form = top_node.find %Q(form[action="#{add_selected_answer_path(111)}"])
      comments_form.should have_css 'input[name=comment_id][type=hidden][value="222"]'
      comments_form.should have_css 'input[name=commit][type=submit][value="Add this guess"]'

      response.body.should include 'This photo was added to the group at 12:00 AM, January  1, 2011.'
      # See admin/photos_controller_spec for more on the sidebar

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
      mock(Comment).add_selected_answer('2', 'username') { raise Photo::AddAnswerError, 'Sorry' }
      post :add_selected_answer, :id => '1', :comment_id => '2', :username => 'username'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end

  end

  describe '#add_entered_answer' do
    it "adds an entered answer" do
      mock(Photo).add_entered_answer 1, 'username', 'answer text'
      mock_clear_page_cache
      post :add_entered_answer, :id => '1', :username => 'username', :answer_text => 'answer text'
      redirects_to_edit_path 1
    end

    it "notifies the user if there was an error" do
      mock(Photo).add_entered_answer(1, 'username', 'answer text') { raise Photo::AddAnswerError, 'Sorry' }
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

  describe '#update_from_flickr' do
    it 'just redirects to the edit page with update_from_flickr=true' do
      get :update_from_flickr, :id => '1'
      redirects_to_edit_path 1, :update_from_flickr => true
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

      redirects_to_edit_path photo, :update_from_flickr => true

    end

    it 'handles https when redirecting to a photo' do
      photo = Photo.make :flickrid => '0123456789' # must be all digits like the real thing
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :edit_in_gww, :from => "https://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      redirects_to_edit_path photo, :update_from_flickr => true

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :edit_in_gww, :from => 'http://www.flickr.com/photos/person_flickrid/0123456789/'

      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Sorry/

    end

    it 'punts unknown URLs' do
      get :edit_in_gww, :from => 'http://www.notflickr.com/'

      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

  def redirects_to_edit_path(photo_or_id, options = {})
    response.should redirect_to edit_admin_photo_path photo_or_id, options
  end

end
