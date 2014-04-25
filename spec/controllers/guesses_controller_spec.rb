require 'spec_helper'

describe GuessesController do
  render_views

  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = [ Guess.make(1) ]
      stub(Guess).longest { longest }
      shortest = [ Guess.make(2) ]
      stub(Guess).shortest { shortest }
      get :longest_and_shortest

      response.should be_success
      response.body.should have_link '1_guessed_photo_poster_username'
      response.body.should have_link '2_guesser_username'
      response.body.should have_link '1_guessed_photo_poster_username'
      response.body.should have_link '2_guesser_username'

    end
  end
  
end
