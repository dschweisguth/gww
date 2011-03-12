require 'spec_helper'

describe WheresiesController do
  integrate_views
  without_transactions

  describe '#show' do
    it 'renders the page' do
      most_points_in_year = Person.make
      most_points_in_year[:points] = 111
      stub(Person).most_points_in { [ most_points_in_year ] }

      most_posts_in_year = Person.make
      most_posts_in_year[:posts] = 222
      stub(Person).most_posts_in { [ most_posts_in_year ] }

      rookie_with_most_points_in_year = Person.make
      rookie_with_most_points_in_year[:points] = 333
      stub(Person).rookies_with_most_points_in { [ rookie_with_most_points_in_year ] }

      rookie_with_most_posts_in_year = Person.make
      rookie_with_most_posts_in_year[:posts] = 444
      stub(Person).rookies_with_most_posts_in { [ rookie_with_most_posts_in_year ] }

      most_viewed_in_year = Photo.make
      most_viewed_in_year[:views] = 555
      stub(Photo).most_viewed_in(2010) { [ most_viewed_in_year ] }

      most_commented_in_year = Photo.make
      most_commented_in_year[:comments] = 666
      stub(Photo).most_commented_in(2010) { [ most_commented_in_year ] }

      longest_in_year_photo = Photo.make :dateadded => Time.local(2010).getutc
      longest_in_year = Guess.make :photo => longest_in_year_photo,
        :guessed_at => Time.local(2011).getutc
      stub(Guess).longest_in { [ longest_in_year ] }

      shortest_in_year_photo = Photo.make :dateadded => Time.local(2010).getutc
      shortest_in_year = Guess.make :photo => shortest_in_year_photo,
        :guessed_at => Time.local(2010, 1, 1, 0, 0, 1).getutc
      stub(Guess).shortest_in { [ shortest_in_year ] }

      get :show, :year => 2010
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'div' do
        with_tag 'h3', :text => 'Most points in 2010'
        with_tag 'td', :text => '333'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => 'Most posts in 2010'
        with_tag 'td', :text => '444'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => 'Most points in 2010'
        with_tag 'td', :text => '111'
      end
      response.should have_tag 'div' do
        with_tag 'h3', :text => 'Most posts in 2010'
        with_tag 'td', :text => '222'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => 'Most-viewed photos of 2010'
        with_tag 'td', :text => '555'
      end
      response.should have_tag 'div' do
        with_tag 'h2', :text => 'Most-commented photos of 2010'
        with_tag 'td', :text => '666'
      end
      response.should have_tag 'td', :text => '1&nbsp;year'
      response.should have_tag 'td', :text => '1&nbsp;second'
    end
  end

end
