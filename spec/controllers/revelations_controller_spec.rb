describe RevelationsController do
  render_views

  describe '#longest' do
    it 'renders the page' do
      revelation = build_stubbed :revelation
      allow(Revelation).to receive(:longest) { [revelation] }
      get :longest

      response.should be_success
      response.body.should have_link revelation.photo.person.username

    end
  end

end
