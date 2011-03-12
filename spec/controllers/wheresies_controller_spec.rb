require 'spec_helper'

describe WheresiesController do
  integrate_views
  without_transactions

  describe '#show' do
    it 'renders the page' do
      stub(ScoreReport).first { ScoreReport.make :created_at => Time.local(2009).getutc }
      stub(Time).now { Time.local(2010) }

      year = 2010

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

      get :show, :year => year.to_s
      #noinspection RubyResolve
      response.should be_success

      response.should have_tag 'a[href=/wheresies/2009]', :text => '2009'
      response.should_not have_tag 'a[href=/wheresies/2010]'

      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most points in #{year}"
        with_tag 'td', :text => '333'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most posts in #{year}"
        with_tag 'td', :text => '444'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most points in #{year}"
        with_tag 'td', :text => '111'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => "Most posts in #{year}"
        with_tag 'td', :text => '222'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => "Most-viewed photos of #{year}"
        with_tag 'td', :text => '555'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => "Most-commented photos of #{year}"
        with_tag 'td', :text => '666'
      end
      response.should have_tag 'td', :text => '1&nbsp;year'
      response.should have_tag 'td', :text => '1&nbsp;second'
    end

    it 'bails out if the year is invalid' do
      stub(ScoreReport).first { ScoreReport.make :created_at => Time.local(2010).getutc }
      stub(Time).now { Time.local(2010) }
      lambda { get :show, :year => "2011" }.should raise_error ActiveRecord::RecordNotFound
    end

  end

end
