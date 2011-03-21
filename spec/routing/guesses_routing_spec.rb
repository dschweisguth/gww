require 'spec_helper'

describe GuessesController do
  without_transactions

  describe 'longest_and_shortest' do
    it { should have_named_route :longest_and_shortest_guesses, '/guesses/longest_and_shortest' }
    it { should route(:get, '/guesses/longest_and_shortest').to :controller => 'guesses', :action => 'longest_and_shortest' }
  end

end
