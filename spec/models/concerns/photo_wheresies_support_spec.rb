describe PhotoWheresiesSupport do
  describe '.most_viewed_in_year' do
    it 'lists photos' do
      photo = create :photo, dateadded: Time.local(2010).getutc
      Photo.most_viewed_in(2010).should == [ photo ]
    end

    it 'sorts by views' do
      photo1 = create :photo, dateadded: Time.local(2010).getutc, views: 0
      photo2 = create :photo, dateadded: Time.local(2010).getutc, views: 1
      Photo.most_viewed_in(2010).should == [ photo2, photo1 ]
    end

    it 'ignores photos from before the year' do
      create :photo, dateadded: Time.local(2009).getutc
      Photo.most_viewed_in(2010).should == []
    end

    it 'ignores photos from after the year' do
      create :photo, dateadded: Time.local(2011).getutc
      Photo.most_viewed_in(2010).should == []
    end

  end

  describe '.most_faved_in_year' do
    it 'lists photos' do
      photo = create :photo, dateadded: Time.local(2010).getutc
      Photo.most_faved_in(2010).should == [ photo ]
    end

    it 'sorts by faves' do
      photo1 = create :photo, dateadded: Time.local(2010).getutc, faves: 0
      photo2 = create :photo, dateadded: Time.local(2010).getutc, faves: 1
      Photo.most_faved_in(2010).should == [ photo2, photo1 ]
    end

    it 'ignores photos from before the year' do
      create :photo, dateadded: Time.local(2009).getutc
      Photo.most_faved_in(2010).should == []
    end

    it 'ignores photos from after the year' do
      create :photo, dateadded: Time.local(2011).getutc
      Photo.most_faved_in(2010).should == []
    end

  end

  describe '.most_commented_in_year' do
    it 'lists photos' do
      photo = create :photo, dateadded: Time.local(2010).getutc
      create :comment, photo: photo
      Photo.most_commented_in(2010).should == [ photo ]
    end

    it 'sorts by comment count' do
      photo1 = create :photo, dateadded: Time.local(2010).getutc
      create :comment, photo: photo1
      photo2 = create :photo, dateadded: Time.local(2010).getutc
      create :comment, photo: photo2
      create :comment, photo: photo2
      Photo.most_commented_in(2010).should == [ photo2, photo1 ]
    end

    it 'ignores photos from before the year' do
      photo = create :photo, dateadded: Time.local(2009).getutc
      create :comment, photo: photo
      Photo.most_commented_in(2010).should == []
    end

    it 'ignores photos from after the year' do
      photo = create :photo, dateadded: Time.local(2011).getutc
      create :comment, photo: photo
      Photo.most_commented_in(2010).should == []
    end

    it "ignores comments by the poster" do
      photo = create :photo, dateadded: Time.local(2010).getutc
      create :comment, photo: photo, flickrid: photo.person.flickrid
      Photo.most_commented_in(2010).should == []
    end

  end

end
