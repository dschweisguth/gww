require 'spec_helper'

describe Admin::GuessesController do
  integrate_views

  describe '#report' do
    it 'renders the page' do
      most_recent_update = FlickrUpdate.new_for_test :created_at => Time.local(2011)
      penultimate_update = FlickrUpdate.new_for_test :created_at => Time.local(2011, 1, 4)
      stub(FlickrUpdate).all { [ most_recent_update, penultimate_update ] }

      person0 = Person.new_for_test
      person1 = Person.new_for_test
      person2 = Person.new_for_test

      guess11 = Guess.new_for_test :label => 11, :person => person1
      guess21 = Guess.new_for_test :label => 21, :person => person2
      guess22 = Guess.new_for_test :label => 22, :person => person2
      mock(Guess).all_since.with(most_recent_update) { [ guess11, guess21, guess22 ] }

      revealed_photo11 = Photo.new_for_test :label => 11, :person => person1
      revealed_photo21 = Photo.new_for_test :label => 21, :person => person2
      revealed_photo22 = Photo.new_for_test :label => 22, :person => person2
      revelation11 = Revelation.new_for_test :label => 11, :photo => revealed_photo11
      revelation21 = Revelation.new_for_test :label => 21, :photo => revealed_photo21
      revelation22 = Revelation.new_for_test :label => 22,  :photo => revealed_photo22
      mock(Revelation).all_since.with(most_recent_update) { [ revelation11, revelation21, revelation22 ] }

      stub(Person).high_scorers.with(7) { [ person2, person1 ] }
      stub(Person).high_scorers.with(30) { [ person2, person1 ] }

      mock(Photo).count_since.with(penultimate_update) { 6 }
      mock(Photo).unfound_or_unconfirmed_count { 1234 }

      # Note that we're ignoring the test guesses' photos' people
      people = [ person0, person1, person2 ]
      stub(Person).all { people }

      mock(Photo).add_posts.with(people)
      person0[:posts] = 0
      person1[:posts] = 1
      person2[:posts] = 2

      mock(Person).by_score.with(people) { { 0 => [ person0 ], 1 => [ person1 ], 2 => [ person2 ] } }

      get :report

      #noinspection RubyResolve
      response.should be_success

    end
  end

end
