describe WheresiesController do
  describe '#show' do
    it "bails out if the year is invalid" do
      allow(Time).to receive(:now).and_return(Time.local 2010)
      allow(ScoreReport).to receive(:minimum).and_return(Time.local(2010).getutc)
      expect { get :show, year: '2011' }.to raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      allow(Time).to receive(:now).and_return(Time.local 2010)
      year = 2009
      allow(ScoreReport).to receive(:minimum).and_return(Time.local(year).getutc)
      allow(WheresiesPerson).to receive(:most_points_in).with(year).and_return([])
      allow(WheresiesPerson).to receive(:most_posts_in).with(year).and_return([])
      allow(WheresiesPerson).to receive(:rookies_with_most_points_in).with(year).and_return([])
      allow(WheresiesPerson).to receive(:rookies_with_most_posts_in).with(year).and_return([])
      allow(WheresiesPhoto).to receive(:most_viewed_in).with(year).and_return([])
      allow(WheresiesPhoto).to receive(:most_faved_in).with(year).and_return([])
      allow(WheresiesPhoto).to receive(:most_commented_in).with(year).and_return([])
      allow(WheresiesGuess).to receive(:longest_in).with(year).and_return([])
      allow(WheresiesGuess).to receive(:shortest_in).with(year).and_return([])
      get :show, year: year.to_s
      expect(response).to be_success
      expect(response.body).not_to have_css 'h1', text: "#{year} Wheresies (preliminary)"
    end

  end
end
