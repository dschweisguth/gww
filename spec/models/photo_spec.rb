require 'spec_helper'

describe Photo do
  describe '#person' do
    it { should belong_to :person }
  end
  
  it { should have_many :comments }

  it { should have_many :guesses }

  it { should have_one :revelation }

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  it { should validate_presence_of :farm }

  it { should validate_presence_of :server }

  it { should validate_presence_of :secret }

  it { should validate_presence_of :dateadded }

  it { should validate_presence_of :mapped }

  # TODO Dave mapped must be 'true' or 'false'

  it { should validate_presence_of :lastupdate }

  it { should validate_presence_of :seen_at }

  it { should validate_presence_of :game_status }

  # TODO Dave game_status must have certain values

  it { should validate_presence_of :views }

  it { should validate_presence_of :member_comments }

  it { should validate_presence_of :member_questions }

end
