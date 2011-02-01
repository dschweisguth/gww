require 'spec_helper'

describe GuessesController do
  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = [ Guess.new :guess_text => "guess 1" ]
      stub(Guess).longest { longest }
      shortest = [ Guess.new :guess_text => "guess 2" ]
      stub(Guess).shortest { shortest }
      get :longest_and_shortest
      assigns[:longest_guesses].should == longest
      assigns[:shortest_guesses].should == shortest
      response.should render_template('guesses/longest_and_shortest')
    end
  end
end
