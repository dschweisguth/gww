require 'spec_helper'

describe GuessesController do
  integrate_views

  describe '#nemeses' do
    it "renders the page" do
      guesser = Person.make 'guesser'
      stub(guesser).id { 666 }
      poster = Person.make 'poster'
      stub(poster).id { 777 }
      guesser[:poster] = poster
      guesser[:bias] = 2.5
      stub(Person).nemeses { [ guesser ] }
      get :nemeses

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag "a[href=/people/show/#{guesser.id}]", "guesser_username"
      response.should have_tag "a[href=/people/show/#{poster.id}]", "poster_username"
      response.should have_tag 'td', '%.3f' % guesser[:bias].to_s

    end
  end

  describe '#longest_and_shortest' do
    it 'renders the page' do
      longest = [ Guess.make 1 ]
      stub(Guess).longest { longest }
      shortest = [ Guess.make 2 ]
      stub(Guess).shortest { shortest }
      get :longest_and_shortest

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a', /1_guess_poster_username/
      response.should have_tag 'a', /2_guesser_username/
      response.should have_tag 'a', /1_guess_poster_username/
      response.should have_tag 'a', /2_guesser_username/

    end
  end
  
end
