require 'spec_helper'

describe WheresiesController do
  render_views
  without_transactions

  describe '#show' do
    it 'renders the page' do
      stub_queries 2009, 2010, 2010
      get :show, :year => '2010'

      #noinspection RubyResolve
      response.should be_success

      response.should have_selector 'a', :href => wheresies_path(2009), :content => '2009'
      response.should_not have_selector 'a', :href => wheresies_path(2010)

      response.should have_selector 'h1' do |text|
        text.should contain '2010 Wheresies (preliminary)'
      end

      response.should have_selector 'div' do |content|
        content.should have_selector 'h3', :content => "Most points in 2010"
        content.should have_selector 'td', :content => '333'
      end
      response.should have_selector 'div' do |content|
        content.should have_selector 'h3', :content => "Most posts in 2010"
        content.should have_selector 'td', :content => '444'
      end
      response.should have_selector 'div' do |content|
        content.should have_selector 'h3', :content => "Most points in 2010"
        content.should have_selector 'td', :content => '111'
      end
      response.should have_selector 'div' do |content|
        content.should have_selector 'h3', :content => "Most posts in 2010"
        content.should have_selector 'td', :content => '222'
      end
      response.should have_selector 'div' do |content|
        content.should have_selector 'h2', :content => "Most-viewed photos of 2010"
        content.should have_selector 'td', :content => '555'
      end
      response.should have_selector 'div' do |content|
        content.should have_selector 'h2', :content => "Most-commented photos of 2010"
        content.should have_selector 'td', :content => '666'
      end
      response.should have_selector 'td', :content => '1&nbsp;year'
      response.should have_selector 'td', :content => '1&nbsp;second'

    end

    it 'bails out if the year is invalid' do
      stub_queries 2010, 2010, 2011
      lambda { get :show, :year => '2011' }.should raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      stub_queries 2009, 2010, 2009
      get :show, :year => '2009'
      response.should_not have_selector 'h1', :content => '2009 Wheresies (preliminary)'
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
      :commented_at => Time.local(year).getutc + 1.year
    stub(Guess).longest_in(year) { [ longest_in_year ] }

    shortest_in_year_photo = Photo.make :dateadded => Time.local(year).getutc
    shortest_in_year = Guess.make :photo => shortest_in_year_photo,
      :commented_at => Time.local(year).getutc + 1.second
    stub(Guess).shortest_in(year) { [ shortest_in_year ] }

  end

end
