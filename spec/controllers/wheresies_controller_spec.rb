describe WheresiesController do
  render_views

  describe '#show' do

    it "bails out if the year is invalid" do
      stub(Time).now { Time.local 2010 }
      stub(ScoreReport).order.stub!.first { build_stubbed :score_report, created_at: Time.local(2010).getutc }
      lambda { get :show, year: '2011' }.should raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      stub(Time).now { Time.local 2010 }
      year = 2009
      stub(ScoreReport).order.stub!.first { build_stubbed :score_report, created_at: Time.local(year).getutc }
      stub(Person).most_points_in(year) { [] }
      stub(Person).most_posts_in(year) { [] }
      stub(Person).rookies_with_most_points_in(year) { [] }
      stub(Person).rookies_with_most_posts_in(year) { [] }
      stub(Photo).most_viewed_in(year) { [] }
      stub(Photo).most_faved_in(year) { [] }
      stub(Photo).most_commented_in(year) { [] }
      stub(Guess).longest_in(year) { [] }
      stub(Guess).shortest_in(year) { [] }
      get :show, year: year.to_s
      response.should be_success
      response.body.should_not have_css 'h1', text: "#{year} Wheresies (preliminary)"
    end

  end

end
