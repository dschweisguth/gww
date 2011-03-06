require 'spec_helper'

class Subject < ApplicationController
  include ScoreReportsControllerSupport
end

describe Subject do
  without_transactions

  before do
    @subject = Subject.new
  end

  describe '#add_changes_in_standings' do
    it "" do
      winner = Person.make 1, :username => 'winner'
      loser = Person.make 2, :username => 'loser'
      people = [ winner, loser ]
      people_by_score = { 2 => [ winner ], 1 => [ loser ] }
      guessers = [ [ winner, [] ] ]
      stub(Person).by_score(people, Time.utc(2010)) { { 1 => [ loser ], 0 => [ winner ] } }
      @subject.add_changes_in_standings people_by_score, people, Time.utc(2010), guessers
      winner[:change_in_standings].should == 'moved up to 1st place!'
    end
  end

  describe '#add_place' do
    it "adds their place to each person" do
      person = Person.make
      people_by_score = { 2 => [ person ] }
      @subject.add_place people_by_score, :place
      person[:place].should == 1
    end

    it "gives a lower (numerically greater) place to people with lower scores" do
      first = Person.make 1
      second = Person.make 2
      people_by_score = { 3 => [ first ], 2 => [ second ] }
      @subject.add_place people_by_score, :place
      first[:place].should == 1
      second[:place].should == 2
    end

  end

end
