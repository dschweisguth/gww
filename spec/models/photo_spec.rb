require 'spec_helper'

describe Photo do
  it 'belongs to a person' do
    should belong_to :person
  end

  it 'has many comments' do
    should have_many :comments
  end

  it 'has many guesses' do
    should have_many :guesses
  end

  it 'has one revelation' do
    should have_one :revelation
  end

end
