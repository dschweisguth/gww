require 'spec_helper'

describe Admin::GuessesHelper do
  describe '#escape_username' do
    it 'surrounds the dot in a username that looks like a domain name with spaces' do
      helper.escape_username('m.bibelot').should == 'm . bibelot'
    end

    it 'does so regardless of capitalization' do
      helper.escape_username('KayVee.INC').should == 'KayVee . INC'
    end

    it 'does nothing if the dot is preceded by a space' do
      helper.escape_username('KayVee .INC').should == 'KayVee .INC'
    end

    it 'does nothing if the dot is followed by a space' do
      helper.escape_username('KayVee. INC').should == 'KayVee. INC'
    end

  end

  describe '#link_to_person' do
    it "returns a link to the person's page" do
      person = Person.create_for_test!
      helper.link_to_person(person).should ==
        "<a href=\"http://test.host/people/show/#{person.id}\">username</a>"
    end

    it "escapes HTML special characters in the person's username" do
      person = Person.create_for_test! :username => 'try&catch>me'
      helper.link_to_person(person).should ==
        "<a href=\"http://test.host/people/show/#{person.id}\">try&amp;catch&gt;me</a>"
    end

  end

end
