require 'spec_helper'
require 'support/model_factory'

describe PeopleController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      person = Person.create_for_test!
      person[:guess_count] = 1
      person[:post_count] = 1
      person[:guesses_per_day] = 1.0
      person[:posts_per_guess] = 1.0
      person[:guess_speed] = 1.0
      person[:be_guessed_speed] = 1.0
      person[:comments_to_guess] = 1.0
      person[:comments_to_be_guessed] = 1.0
      stub(Person).all_sorted.with('score', '+') { [ person ] }
      get :list, :sorted_by => 'score', :order => '+'

      response.should render_template('people/list')
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
      guess = Guess.create_for_test! :guessed_at => report_day
      (0 .. 3).each { |division| top_guessers[division][0].scores[1] = [ guess.person ] }
      stub(Person).top_guessers { top_guessers }
      get :top_guessers

      response.should render_template 'people/top_guessers'
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
          with_tag "a[href=/people/show/#{guess.person.id}]", :text => 'guesser_username'
        end
      end
    end

  end

  describe '#show' do
    it 'renders the page' do
      person = Person.new_for_test
      stub(Person).find { person }
      stub(Person).standing { [ 1, false ] }
      person_with_score = person.clone
      person_with_score[:score] = 1
      stub(Person).high_scorers.with(7) { [ person_with_score ] }
      stub(Person).high_scorers.with(30) { [ person_with_score ] }
      first_guess = Guess.new_for_test :label => 'first_guess'
      first_guess[:place] = 1
      stub(Guess).first { first_guess }
      first_post = Photo.new_for_test :label => 'first_post'
      first_post[:place] = 1
      stub(Photo).first { first_post }
      oldest_guess = Guess.new_for_test :label => 'oldest_guess'
      oldest_guess[:place] = 1
      stub(Guess).oldest { oldest_guess }
      fastest_guess = Guess.new_for_test :label => 'fastest_guess'
      fastest_guess[:place] = 1
      stub(Guess).fastest { fastest_guess }
      longest_lasting_guess = Guess.new_for_test :label => 'longest_lasting_guess'
      longest_lasting_guess[:place] = 1
      stub(Guess).longest_lasting { longest_lasting_guess }
      shortest_lasting_guess = Guess.new_for_test :label => 'shortest_lasting_guess'
      shortest_lasting_guess[:place] = 1
      stub(Guess).shortest_lasting { shortest_lasting_guess }
      #noinspection RubyResolve
      stub(Guess).find_all_by_person_id { [Guess.new_for_test(:label => 'all1'), Guess.new_for_test(:label => 'all2') ] }
      stub(Photo).all { [ Photo.new_for_test :label => 'unfound' ] }
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id_and_game_status { [ Photo.new_for_test :label => 'revealed' ] }
      #noinspection RubyResolve
      stub(Photo).find_all_by_person_id { [ Photo.new_for_test :label => 'found' ] }
      get :show, :id => person.id

      response.should render_template 'people/show'
      response.should have_text /username is in 1st place with a score of 2./
      response.should have_tag 'strong', :text => /username has correctly guessed 2 photos/
      response.should have_tag 'strong', :text => /username has posted 1 photo/
      response.should have_text /1 remains unfound/
      response.should have_text /1 was revealed/

    end
  end

end
