class GuessesController < ApplicationController
  caches_page :longest_and_shortest
  def longest_and_shortest
    @longest_guesses = Guess.longest
    @shortest_guesses = Guess.shortest
  end
end
