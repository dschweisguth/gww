require 'spec_helper'

describe GuessesController do
  describe 'routing' do
    it 'routes to a plain action' do
      { :get => '/guesses/longest_and_shortest' }.should route_to \
        :controller => 'guesses', :action => 'longest_and_shortest'
    end
  end
end
