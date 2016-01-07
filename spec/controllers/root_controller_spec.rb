describe RootController do
  render_views

  describe '#index' do
    it 'renders the page' do
      allow(FlickrUpdate).to receive(:latest) { build_stubbed :flickr_update, created_at: Time.local(2011).getutc }
      allow(ScoreReport).to receive(:minimum) { Time.local(2011).getutc }
      get :index

      expect(response).to be_success
      expect(response.body).to include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and is still running. An update takes about an hour.'
      expect(response.body).to have_link '2011', href: wheresies_path(2011)

    end

    it 'reports a completed update' do
      allow(FlickrUpdate).to receive(:latest) { build_stubbed :flickr_update, created_at: Time.local(2011), completed_at: Time.local(2001, 1, 1, 0, 6) }
      allow(ScoreReport).to receive(:minimum) { Time.local(2011).getutc }
      get :index

      expect(response).to be_success
      expect(response.body).to include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and completed at Monday, January  1,  0:06 PST.'

    end

  end

  describe '#about' do
    it 'renders the page' do
      get :about
      expect(response).to be_success
      expect(response.body).to have_link 'Tomas Apodaca', href: 'https://www.flickr.com/people/tma/'
    end
  end

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      expect(response).to be_success
      expect(response.body).to have_css 'h2', text: 'To add "View in GWW" to your bookmarks,'
    end
  end

  describe '#about_auto_mapping' do
    it 'renders the page' do
      get :about_auto_mapping
      expect(response).to be_success
    end
  end

end
