require 'spec_helper'

describe WheresiesController do
  integrate_views
  without_transactions

  describe '#show' do
    it 'renders the page' do
      stub_queries 2009, 2010, 2010
      get :show, :year => '2010'

      #noinspection RubyResolve
      response.should be_success

      response.should have_tag "a[href=#{wheresies_path 2009}]", :text => '2009'
      response.should_not have_tag "a[href=#{wheresies_path 2010}]"

      response.should have_tag 'h1', :text => /2010 Wheresies \(preliminary\)/

      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most points in 2010"
        with_tag 'td', :text => '333'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most posts in 2010"
        with_tag 'td', :text => '444'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most points in 2010"
        with_tag 'td', :text => '111'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most posts in 2010"
        with_tag 'td', :text => '222'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => "Most-viewed photos of 2010"
        with_tag 'td', :text => '555'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => "Most-commented photos of 2010"
        with_tag 'td', :text => '666'
      end
      response.should have_tag 'td', :text => '1&nbsp;year'
      response.should have_tag 'td', :text => '1&nbsp;second'

    end

    it 'bails out if the year is invalid' do
      stub_queries 2010, 2010, 2011
      lambda { get :show, :year => '2011' }.should raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      stub_queries 2009, 2010, 2009
      get :show, :year => '2009'
      response.should_not have_tag 'h1', :text => /2009 Wheresies \(preliminary\)/
    end

  end

  def stub_queries(first_year, current_year, year)
    stub(ScoreReport).first { ScoreReport.make :created_at => Time.local(first_year).getutc }
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

    most_commented_in_year = Photo.make
    most_commented_in_year[:comments] = 666
    stub(Photo).most_commented_in(year) { [ most_commented_in_year ] }

    longest_in_year_photo = Photo.make :dateadded => Time.local(year).getutc
    longest_in_year = Guess.make :photo => longest_in_year_photo,
      :guessed_at => Time.local(year).getutc + 1.year
    stub(Guess).longest_in(year) { [ longest_in_year ] }

    shortest_in_year_photo = Photo.make :dateadded => Time.local(year).getutc
    shortest_in_year = Guess.make :photo => shortest_in_year_photo,
      :guessed_at => Time.local(year).getutc + 1.second
    stub(Guess).shortest_in(year) { [ shortest_in_year ] }

  end

end
