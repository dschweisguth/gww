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
    it "returns a fully qualified link to the person's page" do
      person = Person.make :id => 666
      helper.link_to_person(person).should ==
        "<a href=\"http://test.host/people/show/#{person.id}\">username</a>"
    end

    it "escapes HTML special characters in the person's username" do
      person = Person.make :id => 666, :username => 'try&catch>me'
      helper.link_to_person(person).should ==
        "<a href=\"http://test.host/people/show/#{person.id}\">try&amp;catch&gt;me</a>"
    end

  end

  describe '#image_for_star' do
    expected = {
      :bronze => 'http://test.host/images/star-padded-bronze.gif',
      :silver => 'http://test.host/images/star-padded-silver.gif',
      :gold => 'http://test.host/images/star-padded-gold-animated.gif'
    }
    expected.keys.each do |star|
      it "returns #{expected[star]} given a #{star} star" do
        helper.image_for_star(star).should == expected[star]
      end
    end
  end

end
