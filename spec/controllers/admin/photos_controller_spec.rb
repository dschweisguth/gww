describe Admin::PhotosController do
  describe 'collections' do
    let(:photo) { build_stubbed :admin_photos_photo }

    describe '#unfound' do
      before do
        allow(AdminPhotosPhoto).to receive(:unfound_or_unconfirmed) { [photo] }
      end

      it "renders the page" do
        allow(photo).to receive(:tags) { [] }
        get :unfound
        lists_photo
      end

      it "highlights a photo tagged foundinSF" do
        tag = build_stubbed :tag, photo: photo, raw: 'foundinSF'
        allow(photo).to receive(:tags) { [tag] }
        get :unfound
        tr = top_node.all('tr')[1]
        expect(tr.all('td')[5].text).to eq('foundinSF')
        expect(tr['class']).to eq('ready-to-score')
      end

    end

    describe '#inaccessible' do
      it "renders the page" do
        allow(AdminPhotosPhoto).to receive(:inaccessible) { [photo] }
        allow(photo).to receive(:tags) { [] }
        get :inaccessible
        lists_photo
      end
    end

    describe '#multipoint' do
      it "renders the page" do
        allow(AdminPhotosPhoto).to receive(:multipoint) { [photo] }
        allow(photo).to receive(:tags) { [] }
        get :multipoint
        lists_photo
      end
    end

    def lists_photo
      expect(response).to be_success
      expect(response.body).to have_link photo.person.username, href: person_path(photo.person)
      expect(response.body).to have_css 'td', text: 'false'
      expect(response.body).to have_css 'td', text: 'unfound'
      expect(response.body).to have_link 'Edit', href: edit_admin_photo_path(photo, update_from_flickr: true)
    end

  end

  describe '#edit' do
    let(:flickr_update_photo) { build_stubbed :flickr_update_photo, id: 1 }
    let(:admin_photos_photo) { build_stubbed :admin_photos_photo, id: 1 }

    before do
      allow(FlickrUpdatePhoto).to receive(:find_with_associations).with(flickr_update_photo.id) { flickr_update_photo }
      allow(AdminPhotosPhoto).to receive(:find_with_associations).with(admin_photos_photo.id) { admin_photos_photo }
      allow(admin_photos_photo).to receive(:comments) { [] }
      allow(admin_photos_photo).to receive(:guesses) { [] }
      allow(admin_photos_photo).to receive(:revelation) { nil }
      allow(admin_photos_photo).to receive(:tags) { [] }
    end

    it "renders the page without loading comments" do
      get :edit, id: admin_photos_photo.id
      expect(response).to be_success
    end

    it "loads comments and renders the page" do
      allow(FlickrUpdateJob::PhotoUpdater).to receive(:update).with(flickr_update_photo)
      mock_clear_page_cache
      get :edit, id: admin_photos_photo.id, update_from_flickr: true
      expect(response).to be_success
    end

  end

  describe '#add_selected_answer' do
    it "notifies the user if there was an error" do
      expect(AdminPhotosComment).to receive(:add_selected_answer).with('2', 'username') do
        raise AdminPhotosPhoto::AddAnswerError, 'Sorry'
      end
      post :add_selected_answer, id: '1', comment_id: '2', username: 'username'
      redirects_to_edit_path 1
      expect(flash[:notice]).to eq('Sorry')
    end
  end

  describe '#add_entered_answer' do
    it "notifies the user if there was an error" do
      expect(AdminPhotosPhoto).to receive(:add_entered_answer).with(1, 'username', 'answer text') do
        raise AdminPhotosPhoto::AddAnswerError, 'Sorry'
      end
      post :add_entered_answer, id: '1', username: 'username', answer_text: 'answer text'
      redirects_to_edit_path 1
      expect(flash[:notice]).to eq('Sorry')
    end
  end

  describe '#remove_revelation' do
    it "removes a revelation" do
      expect(AdminPhotosComment).to receive(:remove_revelation).with '2'
      mock_clear_page_cache
      post :remove_revelation, id: '1', comment_id: '2'
      redirects_to_edit_path 1
    end
  end

  describe '#update_from_flickr' do
    it "just redirects to the edit page with update_from_flickr=true" do
      get :update_from_flickr, id: '1'
      redirects_to_edit_path 1, update_from_flickr: true
    end
  end

  describe '#edit_in_gww' do
    # This test is probably obsolete, in that Flickr seems to always use https now. But leave it in for a while just in case.
    it "redirects to the given photo" do
      photo = build_stubbed :admin_photos_photo
      allow(AdminPhotosPhoto).to receive(:find_by_flickrid).with(photo.flickrid) { photo }
      get :edit_in_gww, from: url_for_flickr_photo(photo)

      redirects_to_edit_path photo, update_from_flickr: true

    end

    it "handles https when redirecting to a photo" do
      photo = build_stubbed :admin_photos_photo
      allow(AdminPhotosPhoto).to receive(:find_by_flickrid).with(photo.flickrid) { photo }
      get :edit_in_gww, from: url_for_flickr_photo(photo)

      redirects_to_edit_path photo, update_from_flickr: true

    end

    it "punts an unknown photo Flickr ID" do
      allow(AdminPhotosPhoto).to receive(:find_by_flickrid).with('0123456789') { nil }
      get :edit_in_gww, from: 'https://www.flickr.com/photos/person_flickrid/0123456789/'

      expect(response).to redirect_to admin_root_path
      expect(flash[:general_error]).to match(/Sorry/)

    end

    it "punts unknown URLs" do
      get :edit_in_gww, from: 'http://www.notflickr.com/'

      expect(response).to redirect_to admin_root_path
      expect(flash[:general_error]).to match(/Hmmm/)

    end

  end

  def redirects_to_edit_path(photo_or_id, options = {})
    expect(response).to redirect_to edit_admin_photo_path photo_or_id, options
  end

end
