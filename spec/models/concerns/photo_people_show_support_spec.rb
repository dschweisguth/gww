describe PhotoPeopleShowSupport do
  describe '.first_by' do
    let(:poster) { create :person }

    it "returns the poster's first post" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      first = create :photo, person: poster, dateadded: Time.utc(2000)
      Photo.first_by(poster).should == first
    end

    it "ignores other posters' photos" do
      create :photo
      Photo.first_by(poster).should be_nil
    end

  end

  describe '.most_recent_by' do
    let(:poster) { create :person }

    it "returns the poster's most recent post" do
      create :photo, person: poster, dateadded: Time.utc(2000)
      most_recent = create :photo, person: poster, dateadded: Time.utc(2001)
      Photo.most_recent_by(poster).should == most_recent
    end

    it "ignores other posters' photos" do
      create :photo
      Photo.most_recent_by(poster).should be_nil
    end

  end

  describe '.oldest_unfound' do
    let(:poster) { create :person }

    it "returns the poster's oldest unfound" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      first = create :photo, person: poster, dateadded: Time.utc(2000)
      oldest_unfound = Photo.oldest_unfound poster
      oldest_unfound.should == first
      oldest_unfound.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      Photo.oldest_unfound(poster).should be_nil
    end

    it "considers unconfirmed photos" do
      photo = create :photo, person: poster, game_status: 'unconfirmed'
      Photo.oldest_unfound(poster).should == photo
    end

    it "ignores game statuses other than unfound and unconfirmed" do
      photo = create :photo, person: poster, game_status: 'found'
      Photo.oldest_unfound(poster).should be_nil
    end

    it "considers other posters' oldest unfounds when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2000)
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 2
    end

    it "considers unconfirmed photos when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2000), game_status: 'unconfirmed'
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 2
    end

    it "ignores other posters' equally old unfounds when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 1
    end

    it "handles a person with no photos" do
      Photo.oldest_unfound(poster).should be_nil
    end

  end

  describe '.most_commented' do
    let(:poster) { create :person }

    it "returns the poster's most-commented photo" do
      create :photo, person: poster
      first = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: first
      most_commented = Photo.most_commented poster
      most_commented.should == first
      most_commented.other_user_comments.should == 1
      most_commented.place.should == 1
    end

    it "counts comments" do
      second = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: second
      first = create :photo, person: poster, other_user_comments: 2
      create :comment, photo: first
      create :comment, photo: first
      most_commented = Photo.most_commented poster
      most_commented.should == first
      most_commented.other_user_comments.should == 2
      most_commented.place.should == 1
    end

    it "ignores other posters' photos" do
      photo = create :photo, other_user_comments: 1
      create :comment, photo: photo
      Photo.most_commented(poster).should be_nil
    end

    it "considers other posters' photos when calculating place" do
      other_posters_photo = create :photo, other_user_comments: 2
      create :comment, photo: other_posters_photo
      create :comment, photo: other_posters_photo
      photo = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: photo
      Photo.most_commented(poster).place.should == 2
    end

    it "ignores other posters' equally commented photos when calculating place" do
      other_posters_photo = create :photo, other_user_comments: 1
      create :comment, photo: other_posters_photo
      photo = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: photo
      Photo.most_commented(poster).place.should == 1
    end

    it "handles a person with no photos" do
      Photo.most_commented(poster).should be_nil
    end

  end

  describe '.most_viewed' do
    let(:poster) { create :person }

    it "returns the poster's most-viewed photo" do
      create :photo, person: poster
      first = create :photo, person: poster, views: 1
      most_viewed = Photo.most_viewed poster
      most_viewed.should == first
      most_viewed.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      Photo.most_viewed(poster).should be_nil
    end

    it "considers other posters' photos when calculating place" do
      create :photo, views: 1
      photo = create :photo, person: poster
      Photo.most_viewed(poster).place.should == 2
    end

    it "ignores other posters' equally viewed photos when calculating place" do
      create :photo
      photo = create :photo, person: poster
      Photo.most_viewed(poster).place.should == 1
    end

    it "handles a person with no photos" do
      Photo.most_viewed(poster).should be_nil
    end

  end

  describe '.most_faved' do
    let(:poster) { create :person }

    it "returns the poster's most-faved photo" do
      create :photo, person: poster
      first = create :photo, person: poster, faves: 1
      most_faved = Photo.most_faved poster
      most_faved.should == first
      most_faved.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      Photo.most_faved(poster).should be_nil
    end

    it "considers other posters' photos when calculating place" do
      create :photo, faves: 1
      photo = create :photo, person: poster
      Photo.most_faved(poster).place.should == 2
    end

    it "ignores other posters' equally faved photos when calculating place" do
      create :photo
      photo = create :photo, person: poster
      Photo.most_faved(poster).place.should == 1
    end

    it "handles a person with no photos" do
      Photo.most_faved(poster).should be_nil
    end

  end

  describe '.find_with_guesses' do
    it "returns a person's photos, with their guesses and the guesses' people" do
      guess = create :guess
      photos = Photo.find_with_guesses guess.photo.person
      photos.should == [ guess.photo ]
      photos[0].guesses.should == [ guess ]
      photos[0].guesses[0].person.should == guess.person
    end
  end

  describe '#has_obsolete_tags?' do
    %w(found revealed).each do |game_status|
      it "returns true if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_truthy
      end
    end

    it "is case-insensitive" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'UNFOUNDINSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    %w(unfound unconfirmed).each do |game_status|
      it "returns false if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_falsy
      end
    end

    it "returns false if a found photo is tagged something else" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unseeninSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a found photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns true if a found photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

  end

end
