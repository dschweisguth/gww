require 'spec_helper'

describe PeopleController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      person = Person.create_for_test!
      person[:downcased_username] = 'downcased_username'
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
      p response.body
      response.should render_template('people/list')
      response.should have_tag 'a[href=/people/list/sorted-by/score/order/-]', :text => 'Score'
      response.should have_tag "a[href=/people/show/#{person.id}]", :text => 'username'
    end
  end

end
