require 'spec_helper'

describe Admin::PhotosController do
  render_views

  describe 'collections' do
    before do
      @photo = build :photo, id: 1
    end

    describe '#unfound' do
      it 'renders the page' do
        stub(Photo).unfound_or_unconfirmed { [ @photo ] }
        get :unfound
        lists_photo
      end

      it "highlights a photo tagged foundinSF" do
        stub(Photo).unfound_or_unconfirmed { [ @photo ] }
        tag = build :tag, photo: @photo, raw: 'foundinSF'
        stub(@photo).tags { [tag] }
        get :unfound
        tr = top_node.all('tr')[1]
        tr.all('td')[5].text.should == 'foundinSF'
        tr['class'].should == 'ready-to-score'
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
      response.body.should have_link @photo.person.username, href: person_path(@photo.person)
      response.body.should have_css 'td', text: 'false'
      response.body.should have_css 'td', text: 'unfound'
      response.body.should have_link 'Edit', href: edit_admin_photo_path(@photo, update_from_flickr: true)
    end

  end

  describe '#edit' do
    let(:photo) { build :photo, id: 1 }

    before do
      stub(Photo).find_with_associations(photo.id) { photo }
    end

    it 'renders the page without loading comments' do
      get :edit, id: photo.id
      response.should be_success
    end

    it 'loads comments and renders the page' do
      stub(FlickrUpdater).update_photo(photo)
      mock_clear_page_cache
      get :edit, id: photo.id, update_from_flickr: true
      response.should be_success
    end

  end

  describe '#add_selected_answer' do
    it "notifies the user if there was an error" do
      mock(Comment).add_selected_answer('2', 'username') { raise Photo::AddAnswerError, 'Sorry' }
      post :add_selected_answer, id: '1', comment_id: '2', username: 'username'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end
  end

  describe '#add_entered_answer' do
    it "notifies the user if there was an error" do
      mock(Photo).add_entered_answer(1, 'username', 'answer text') { raise Photo::AddAnswerError, 'Sorry' }
      post :add_entered_answer, id: '1', username: 'username', answer_text: 'answer text'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end
  end

  describe '#remove_revelation' do
    it "removes a revelation" do
      mock(Comment).remove_revelation '2'
      mock_clear_page_cache
      post :remove_revelation, id: '1', comment_id: '2'
      redirects_to_edit_path 1
    end
  end

  describe '#remove_guess' do
    it "notifies the user if there was an error" do
      mock(Comment).remove_guess('2') { raise Comment::RemoveGuessError, 'Sorry' }
      post :remove_guess, id: '1', comment_id: '2'
      redirects_to_edit_path 1
      flash[:notice].should == 'Sorry'
    end
  end

  describe '#update_from_flickr' do
    it 'just redirects to the edit page with update_from_flickr=true' do
      get :update_from_flickr, id: '1'
      redirects_to_edit_path 1, update_from_flickr: true
    end
  end

  describe '#edit_in_gww' do
    it 'redirects to the given photo' do
      photo = build :photo, id: 1
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :edit_in_gww, from: "http://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      redirects_to_edit_path photo, update_from_flickr: true

    end

    it 'handles https when redirecting to a photo' do
      photo = build :photo, id: 1
      stub(Photo).find_by_flickrid(photo.flickrid) { photo }
      get :edit_in_gww, from: "https://www.flickr.com/photos/person_flickrid/#{photo.flickrid}/"

      redirects_to_edit_path photo, update_from_flickr: true

    end

    it 'punts an unknown photo Flickr ID' do
      stub(Photo).find_by_flickrid('0123456789') { nil }
      get :edit_in_gww, from: 'https://www.flickr.com/photos/person_flickrid/0123456789/'

      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Sorry/

    end

    it 'punts unknown URLs' do
      get :edit_in_gww, from: 'http://www.notflickr.com/'

      response.should redirect_to admin_root_path
      flash[:general_error].should =~ /Hmmm/

    end

  end

  def redirects_to_edit_path(photo_or_id, options = {})
    response.should redirect_to edit_admin_photo_path photo_or_id, options
  end

end
