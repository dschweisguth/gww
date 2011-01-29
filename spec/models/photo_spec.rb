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

  it 'requires a person' do
    should validate_presence_of :person
  end

  it "doesn't allow person to change" do
    should have_readonly_attribute :person
  end

  it 'requires a flickrid' do
    should validate_presence_of :flickrid
  end

  it "doesn't allow flickrid to change" do
    should have_readonly_attribute :flickrid
  end

  it 'requires a farm' do
    should validate_presence_of :farm
  end

  it 'requires a server' do
    should validate_presence_of :server
  end

  it 'requires a secret' do
    should validate_presence_of :secret
  end

  it 'requires a dateadded' do
    should validate_presence_of :dateadded
  end

  it 'requires a mapped' do
    should validate_presence_of :mapped
  end

  # TODO Dave mapped must be 'true' or 'false'

  it 'requires a lastupdate' do
    should validate_presence_of :lastupdate
  end

  it 'requires a seen_at' do
    should validate_presence_of :seen_at
  end

  it 'requires a game_status' do
    should validate_presence_of :game_status
  end

  # TODO Dave game_status must have certain values

  it 'requires a count of views' do
    should validate_presence_of :views
  end

  it 'requires a count of member comments' do
    should validate_presence_of :member_comments
  end

  it 'requires a count of member questions' do
    should validate_presence_of :member_questions
  end

end
