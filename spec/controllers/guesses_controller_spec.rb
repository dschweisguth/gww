require 'spec_helper'

describe GuessesController do
  integrate_views

  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = [ Guess.new_for_test :label => 1 ]
      stub(Guess).longest { longest }
      shortest = [ Guess.new_for_test :label => 2 ]
      stub(Guess).shortest { shortest }
      get :longest_and_shortest
      response.should render_template('guesses/longest_and_shortest')
      response.should have_tag 'a', /1_guess_poster_username/
      response.should have_tag 'a', /2_guesser_username/
      response.should have_tag 'a', /1_guess_poster_username/
      response.should have_tag 'a', /2_guesser_username/
    end
  end
  
end
