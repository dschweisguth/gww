require 'spec_helper'

describe GuessesController do
  without_transactions

  describe 'longest_and_shortest' do
    it 'has a named route' do
      #noinspection RubyResolve
      longest_and_shortest_path.should == '/guesses/longest_and_shortest'
    end

    it { should route(:get, '/guesses/longest_and_shortest').to :controller => 'guesses', :action => 'longest_and_shortest' }

  end

end
