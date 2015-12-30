describe WheresiesController do
  render_views

  describe '#show' do

    it "bails out if the year is invalid" do
      allow(Time).to receive(:now) { Time.local 2010 }
      allow(ScoreReport).to receive(:minimum) { Time.local(2010).getutc }
      expect { get :show, year: '2011' }.to raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      allow(Time).to receive(:now) { Time.local 2010 }
      year = 2009
      allow(ScoreReport).to receive(:minimum) { Time.local(year).getutc }
      allow(Person).to receive(:most_points_in).with(year) { [] }
      allow(Person).to receive(:most_posts_in).with(year) { [] }
      allow(Person).to receive(:rookies_with_most_points_in).with(year) { [] }
      allow(Person).to receive(:rookies_with_most_posts_in).with(year) { [] }
      allow(Photo).to receive(:most_viewed_in).with(year) { [] }
      allow(Photo).to receive(:most_faved_in).with(year) { [] }
      allow(Photo).to receive(:most_commented_in).with(year) { [] }
      allow(Guess).to receive(:longest_in).with(year) { [] }
      allow(Guess).to receive(:shortest_in).with(year) { [] }
      get :show, year: year.to_s
      expect(response).to be_success
      expect(response.body).not_to have_css 'h1', text: "#{year} Wheresies (preliminary)"
    end

  end

end
