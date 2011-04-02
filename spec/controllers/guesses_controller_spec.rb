require 'spec_helper'

describe GuessesController do
  render_views
  without_transactions

  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = [ Guess.make 1 ]
      stub(Guess).longest { longest }
      shortest = [ Guess.make 2 ]
      stub(Guess).shortest { shortest }
      get :longest_and_shortest

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :content => '1_guessed_photo_poster_username'
      response.should have_selector 'a', :content => '2_guesser_username'
      response.should have_selector 'a', :content => '1_guessed_photo_poster_username'
      response.should have_selector 'a', :content => '2_guesser_username'

    end
  end
  
end
