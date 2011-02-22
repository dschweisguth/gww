require 'spec_helper'
require 'support/model_factory'

describe PeopleController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      sorted_by_param = 'score'
      order_param = '+'

      person = Person.make
      stub(person).id { 666 }
      person[:guess_count] = 1
      person[:post_count] = 1
      person[:guesses_per_day] = 1.0
      person[:posts_per_guess] = 1.0
      person[:guess_speed] = 1.0
      person[:be_guessed_speed] = 1.0
      person[:comments_to_guess] = 1.0
      person[:comments_to_be_guessed] = 1.0
      stub(Person).all_sorted(sorted_by_param, order_param) { [ person ] }
      get :list, :sorted_by => sorted_by_param, :order => order_param

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/people/list/sorted-by/score/order/-]', :text => 'Score'
      response.should have_tag "a[href=/people/show/#{person.id}]", :text => 'username'

    end
  end

  describe '#top_guessers' do
    it 'renders the page' do
      report_day = Time.utc(2011, 1, 3)
      top_guessers = [
        (0 .. 6).map { |i| Period.starting_at report_day - i.days, 1.day },
          [ Period.new report_day.beginning_of_week - 1.day, report_day + 1.day ] +
            (0 .. 4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
          [ Period.new report_day.beginning_of_month, report_day + 1.day ] +
            (0 .. 11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
          [ Period.new report_day.beginning_of_year, report_day + 1.day ]
      ]
      person = Person.make
      stub(person).id { 666 }
      guess = Guess.make :person => person, :guessed_at => report_day
      (0 .. 3).each { |division| top_guessers[division][0].scores[1] = [ person ] }
      stub(Person).top_guessers { top_guessers }
      get :top_guessers

      #noinspection RubyResolve
      response.should be_success
      response_should_have_table "for Monday, January 03 so far ...", guess
      response_should_have_table "for the week of January 02 so far ...", guess
      response_should_have_table "for January 2011 so far ...", guess
      response_should_have_table "for 2011 so far ...", guess

    end

    def response_should_have_table(title, guess)
      response.should have_tag "table" do
        with_tag "th", :text => title
        with_tag "tr" do
          with_tag "td.opening-number", :text => "1"
          with_tag "a[href=/people/show/#{guess.person.id}]", :text => 'username'
        end
      end
    end

  end

  describe '#show' do
    it 'renders the page' do
      person = Person.make
      stub(person).id { 1 }
      person[:score] = 1 # for the high_scorers methods

      stub(Person).find(person.id.to_s) { person }

      stub(Person).standing { [ 1, false ] }

      stub(Person).high_scorers(7) { [ person ] }
      stub(Person).high_scorers(30) { [ person ] }

      first_guess = Guess.make :label => 'first_guess'
      stub(Guess).first_by(person) { first_guess }

      first_post = Photo.make :label => 'first_post'
      stub(Photo).first_by(person) { first_post }

      oldest_guess = Guess.make :label => 'oldest_guess'
      oldest_guess[:place] = 1
      stub(Guess).oldest(person) { oldest_guess }

      fastest_guess = Guess.make :label => 'fastest_guess'
      fastest_guess[:place] = 1
      stub(Guess).fastest(person) { fastest_guess }

      longest_lasting_guess = Guess.make :label => 'longest_lasting_guess'
      longest_lasting_guess[:place] = 1
      stub(Guess).longest_lasting(person) { longest_lasting_guess }

      shortest_lasting_guess = Guess.make :label => 'shortest_lasting_guess'
      shortest_lasting_guess[:place] = 1
      stub(Guess).shortest_lasting(person) { shortest_lasting_guess }

      most_recent_guess = Guess.make :label => 'most_recent_guess'
      stub(Guess).most_recent_by(person) { most_recent_guess }

      most_recent_post = Photo.make :label => 'most_recent_post'
      stub(Photo).most_recent_by(person) { most_recent_post }

      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id(person.id, anything) \
        { [Guess.make(:label => 'all1'), Guess.make(:label => 'all2') ] }

      stub(Photo).all { [ Photo.make :label => 'unfound' ] }

      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id_and_game_status(person.id, 'revealed') \
        { [ Photo.make :label => 'revealed' ] }

      found1 = Guess.make :label => 'found1'
      found1.photo.guesses << found1
      found2 = Guess.make :label => 'found2'
      found2.photo.guesses << found2
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id(person.id, anything) { [ found1.photo, found2.photo ] }

      get :show, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_text /username is in 1st place with a score of 2./
      response.should have_text /username scored the most points in the last week/
      response.should have_text /username scored the most points in the last month/
      response.should have_tag 'strong', :text => /username has correctly guessed 2 photos/
      response.should have_tag 'strong', :text => /username has posted 2 photos/
      response.should have_text /1 remains unfound/
      response.should have_text /1 was revealed/

    end
  end

  describe '#guesses' do
    it 'renders the page' do
      person = Person.make
      stub(person).id { 1 }
      stub(Person).find(person.id.to_s) { person }
      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id(person.id.to_s, anything) { [ Guess.make :person => person ] }
      get :guesses, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 guess by username'
      response.should have_tag 'a', :text => 'guess_poster_username'

    end
  end

  describe '#posts' do
    it 'renders the page' do
      person = Person.make
      stub(person).id { 1 }
      stub(Person).find(person.id.to_s) { person }
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id(person.id.to_s, anything) { [ Photo.make :person => person ] }
      get :posts, :id => person.id

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 photo posted by username'
      response.should have_tag 'img[src=http://farm0.static.flickr.com/server/photo_flickrid_secret_t.jpg]'

    end
  end

  describe '#comments' do
    it 'renders the page' do
      person = Person.make
      stub(person).id { 1 }
      stub(Person).find(person.id.to_s) { person }

      #noinspection RubyResolve
      photo = Photo.make
      stub(Comment).find_by_sql { [ photo ] }

      paginated_photos = [ photo ]
      # Mock methods from will_paginate's version of Array
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).paginate { paginated_photos }

      get :comments, :id => person.id, :page => "2"

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'h1', :text => '1 photo commented on by username'
      response.should have_tag 'a[href=http://www.flickr.com/photos/poster_person_flickrid/photo_flickrid/in/pool-guesswheresf/]', :text => 'Flickr'
      response.should have_tag 'a[href=/photos/show]', :text => 'GWW'
      response.should have_tag 'a[href=/people/show]', :text => 'poster_username'

    end
  end

end
