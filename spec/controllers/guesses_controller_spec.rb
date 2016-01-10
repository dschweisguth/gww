describe GuessesController do
  describe '#longest_and_shortest' do
    it "renders the page" do
      longest = build_stubbed :guess
      allow(Guess).to receive(:longest) { [longest] }
      shortest = build_stubbed :guess
      allow(Guess).to receive(:shortest) { [shortest] }
      get :longest_and_shortest

      expect(response).to be_success
      expect(response.body).to have_link longest.photo.person.username
      expect(response.body).to have_link shortest.person.username
      expect(response.body).to have_link longest.photo.person.username
      expect(response.body).to have_link shortest.person.username

    end
  end
end
