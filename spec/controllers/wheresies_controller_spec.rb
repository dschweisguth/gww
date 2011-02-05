require 'spec_helper'

describe WheresiesController do
  integrate_views

  describe '#index' do
    it 'renders the page' do
      most_points_in_2010 = Person.new_for_test
      most_points_in_2010[:points] = 111
      stub(Person).most_points_in_2010 { [ most_points_in_2010 ] }

      most_posts_in_2010 = Person.new_for_test
      most_posts_in_2010[:posts] = 222
      stub(Person).most_posts_in_2010 { [ most_posts_in_2010 ] }

      rookie_with_most_points_in_2010 = Person.new_for_test
      rookie_with_most_points_in_2010[:points] = 333
      stub(Person).rookies_with_most_points_in_2010 { [ rookie_with_most_points_in_2010 ] }

      rookie_with_most_posts_in_2010 = Person.new_for_test
      rookie_with_most_posts_in_2010[:posts] = 444
      stub(Person).rookies_with_most_posts_in_2010 { [ rookie_with_most_posts_in_2010 ] }

      most_viewed_in_2010 = Photo.new_for_test
      most_viewed_in_2010[:views] = 555
      stub(Photo).most_viewed_in_2010 { [ most_viewed_in_2010 ] }

      most_commented_in_2010 = Photo.new_for_test
      most_commented_in_2010[:comments] = 666
      stub(Photo).most_commented_in_2010 { [ most_commented_in_2010 ] }

      shortest_in_2010_photo = Photo.new_for_test :dateadded => Time.utc(2010)
      shortest_in_2010 = Guess.new_for_test :photo => shortest_in_2010_photo,
        :guessed_at => Time.utc(2010, 1, 1, 0, 0, 1)
      stub(Guess).shortest_in_2010 { [ shortest_in_2010 ] }

      get :index
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
      response.should have_tag 'td', :text => '1&nbsp;second'
    end
  end

end
