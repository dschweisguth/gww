require 'spec_helper'
require 'support/model_factory'

describe 'guesses/longest_and_shortest' do
  it 'should render' do
    assigns[:longest_guesses] = [ Guess.new_for_test :label => 1 ]
    assigns[:shortest_guesses] = [ Guess.new_for_test :label => 2 ]
    render 'guesses/longest_and_shortest'
  end
end
