describe RevelationsController do
  render_views

  describe '#longest' do
    it 'renders the page' do
      revelation = build_stubbed :revelation
      allow(Revelation).to receive(:longest) { [revelation] }
      get :longest

      expect(response).to be_success
      expect(response.body).to have_link revelation.photo.person.username

    end
  end

end
