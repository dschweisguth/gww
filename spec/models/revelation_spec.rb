describe Revelation do

  describe '#comment_text' do
    it { should validate_presence_of :comment_text }

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      create :revelation, comment_text: non_ascii_text
      Revelation.all[0].comment_text.should == non_ascii_text
    end

  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
  end

  describe '#added_at' do
    it { should validate_presence_of :added_at }
  end

  describe '.longest' do
    it 'lists revelations' do
      revelation = create :revelation
      Revelation.longest.should == [ revelation ]
    end

    it 'sorts revelations by the time from post to revelation' do
      photo1 = create :photo, dateadded: Time.utc(2000)
      revelation1 = create :revelation, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      revelation2 = create :revelation, photo: photo2, commented_at: Time.utc(2004)
      Revelation.longest.should == [ revelation2, revelation1 ]
    end

  end

  describe '.all_between' do
    it 'returns all revelations between the given dates' do
      revelation = create :revelation, added_at: Time.utc(2011, 1, 1, 0, 0, 1)
      Revelation.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == [ revelation ]
    end

    it 'ignores revelations made on or before the from date' do
      create :revelation, added_at: Time.utc(2011)
      Revelation.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

    it 'ignores revelations made after the to date' do
      create :revelation, added_at: Time.utc(2011, 1, 1, 0, 0, 2)
      Revelation.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

  end

  describe '#time_elapsed' do
    it 'returns the duration in seconds from post to revelation in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      revelation = Revelation.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      revelation.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the duration in days from post to revelation in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      revelation = Revelation.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      revelation.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end
  end

end
