require 'spec_helper'

describe GuessesController do
  render_views

  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = build :guess
      stub(Guess).longest { [longest] }
      shortest = build :guess
      stub(Guess).shortest { [shortest] }
      get :longest_and_shortest

      response.should be_success
      response.body.should have_link longest.photo.person.username
      response.body.should have_link shortest.person.username
      response.body.should have_link longest.photo.person.username
      response.body.should have_link shortest.person.username

    end
  end
  
end
