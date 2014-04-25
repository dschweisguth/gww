require 'spec_helper'

describe WheresiesController do
  render_views

  describe '#show' do
    it 'renders the page' do
      stub_queries 2009, 2010, 2010
      get :show, :year => '2010'

      response.should be_success

      response.body.should have_link '2009', :href => wheresies_path(2009)
      response.body.should_not have_selector %Q(a[href="#{wheresies_path(2010)}"])

      h1 = top_node.find 'h1'
      h1.text.should include '2010 Wheresies (preliminary)'

      points_and_posts = top_node.all 'body > div > div > div'
      points_and_posts.count.should == 4
      points_and_posts[0].should have_selector 'h3', :text => "Most points in 2010"
      points_and_posts[0].should have_selector 'td', :text => '333'
      points_and_posts[1].should have_selector 'h3', :text => "Most posts in 2010"
      points_and_posts[1].should have_selector 'td', :text => '444'
      points_and_posts[2].should have_selector 'h3', :text => "Most points in 2010"
      points_and_posts[2].should have_selector 'td', :text => '111'
      points_and_posts[3].should have_selector 'h3', :text => "Most posts in 2010"
      points_and_posts[3].should have_selector 'td', :text => '222'

      divs = top_node.all 'body > div > div'
      divs.count.should == 5
      divs[2].should have_selector 'h2', :text => "Most-viewed photos of 2010"
      divs[2].should have_selector 'td', :text => '555'
      divs[3].should have_selector 'h2', :text => "Most-faved photos of 2010"
      divs[3].should have_selector 'td', :text => '666'
      divs[4].should have_selector 'h2', :text => "Most-commented photos of 2010"
      divs[4].should have_selector 'td', :text => '777'

      tables = top_node.all 'body > div > table'
      tables.count.should == 2
      tables[0].all('td').last.text.should == "1\u00A0year"
      tables[1].all('td').last.text.should == "1\u00A0second"

    end

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
