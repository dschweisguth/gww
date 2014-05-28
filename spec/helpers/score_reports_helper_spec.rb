require 'spec_helper'

describe ScoreReportsHelper do

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

  describe '#link_to_person_url' do
    it "returns a fully qualified link to the person's page" do
      person = Person.make
      helper.link_to_person_url(person).should == "<a href=\"#{person_url person}\">#{person.username}</a>"
    end

    it "escapes HTML special characters in the person's username" do
      person = Person.make username: 'try&catch>me'
      helper.link_to_person_url(person).should == "<a href=\"#{person_url person}\">try&amp;catch&gt;me</a>"
    end

  end

  describe '#image_url_for_star' do
    expected = {
      bronze: 'https://farm9.staticflickr.com/8332/8143796058_095478b380_o.gif',
      silver: 'https://farm9.staticflickr.com/8470/8143764201_c938bf6bea_o.gif',
      gold:   'https://farm9.staticflickr.com/8050/8143796020_85a314ced3_o.gif'
    }
    expected.keys.each do |star|
      it "returns #{expected[star]} given a #{star} star" do
        helper.image_url_for_star(star).should == expected[star]
      end
    end
  end

end
