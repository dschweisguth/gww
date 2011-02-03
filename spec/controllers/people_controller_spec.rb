require 'spec_helper'

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
    end
  end

end
