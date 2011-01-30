require 'spec_helper'

describe Photo do
  def valid_attrs
    now = Time.now
    { :flickrid => 'flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, 'mapped' => 'false',
      :lastupdate => now, :seen_at => now, :game_status => 'unfound',
      :views => 0, :member_comments => 0, :member_questions => 0 }
  end

  describe '#person' do
    it { should belong_to :person }
  end
  
  describe '#comments' do
    it { should have_many :comments }
  end

  describe '#guesses' do
    it { should have_many :guesses }
  end

  describe '#revelation' do
    it { should have_one :revelation }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it "requires flickrid to be unique" do
      Photo.create_for_test!
      should validate_uniqueness_of :flickrid
    end
    it { should have_readonly_attribute :flickrid }
  end

  describe '#farm' do
    it { should validate_presence_of :farm }
  end

  describe '#server' do
    it { should validate_presence_of :server }
  end

  describe '#secret' do
    it { should validate_presence_of :secret }
  end

  describe '#dateadded' do
    it { should validate_presence_of :dateadded }
  end

  describe '#mapped' do
    it { should validate_presence_of :mapped }

    %w(false true).each do |value|
      it "accepts '#{value}'" do
        Photo.new(valid_attrs.merge({ :mapped => value })).should be_valid
      end
    end

    it "rejects other values" do
      Photo.new(valid_attrs.merge({ :mapped => 'maybe' })).should_not be_valid
    end

  end

  describe '#lastupdate' do
    it { should validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { should validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { should validate_presence_of :game_status }
  end

  # TODO Dave game_status must have certain values

  describe '#views' do
    it { should validate_presence_of :views }
  end

  describe '#member_comments' do
    it { should validate_presence_of :member_comments }
  end

  describe '#member_questions' do
    it { should validate_presence_of :member_questions }
  end

end
