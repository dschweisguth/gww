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
end
