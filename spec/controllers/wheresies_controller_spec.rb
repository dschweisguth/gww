require 'spec_helper'

describe WheresiesController do
  render_views

  describe '#show' do
    # TODO Dave simplify

    it 'bails out if the year is invalid' do
      stub_queries 2010, 2010, 2011
      lambda { get :show, :year => '2011' }.should raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      stub_queries 2009, 2010, 2009
      get :show, :year => '2009'
      response.body.should_not have_selector 'h1', :text => '2009 Wheresies (preliminary)'
    end

  end

  def stub_queries(first_year, current_year, year)
    stub(ScoreReport).order.stub!.first { ScoreReport.make :created_at => Time.local(first_year).getutc }
    stub(Time).now { Time.local(current_year) }

    most_points_in_year = Person.make
    most_points_in_year[:points] = 111
    stub(Person).most_points_in(year) { [ most_points_in_year ] }

    most_posts_in_year = Person.make
    most_posts_in_year[:posts] = 222
    stub(Person).most_posts_in(year) { [ most_posts_in_year ] }

    rookie_with_most_points_in_year = Person.make
    rookie_with_most_points_in_year[:points] = 333
    stub(Person).rookies_with_most_points_in(year) { [ rookie_with_most_points_in_year ] }

    rookie_with_most_posts_in_year = Person.make
    rookie_with_most_posts_in_year[:posts] = 444
    stub(Person).rookies_with_most_posts_in(year) { [ rookie_with_most_posts_in_year ] }

    most_viewed_in_year = Photo.make
    most_viewed_in_year[:views] = 555
    stub(Photo).most_viewed_in(year) { [ most_viewed_in_year ] }

    most_faved_in_year = Photo.make
    most_faved_in_year[:faves] = 666
    stub(Photo).most_faved_in(year) { [ most_faved_in_year ] }

    most_commented_in_year = Photo.make
    most_commented_in_year[:comments] = 777
    stub(Photo).most_commented_in(year) { [ most_commented_in_year ] }

    longest_in_year_photo = Photo.make :dateadded => Time.local(year).getutc
    longest_in_year = Guess.make :photo => longest_in_year_photo,
      :commented_at => Time.local(year).getutc + 1.year
    stub(Guess).longest_in(year) { [ longest_in_year ] }

    shortest_in_year_photo = Photo.make :dateadded => Time.local(year).getutc
    shortest_in_year = Guess.make :photo => shortest_in_year_photo,
      :commented_at => Time.local(year).getutc + 1.second
    stub(Guess).shortest_in(year) { [ shortest_in_year ] }

  end

end
