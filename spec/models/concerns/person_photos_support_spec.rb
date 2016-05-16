describe PersonPhotosSupport do
  describe '.photo_search_autocompletions' do
    let(:person) { create :person }

    context "person has no photos" do
      before do
        person.photo_count = 0
      end

      it "finds a username" do
        expect(Person.photo_search_autocompletions(person.username, nil)).to eq([autocompletion(person)])
      end

      it "finds a realname" do
        expect(Person.photo_search_autocompletions(person.realname, nil)).to eq([autocompletion(person)])
      end

      it "doesn't find anything when it shouldn't" do
        expect(Person.photo_search_autocompletions("not their username or realname", nil)).to eq([])
      end
    end

    it "counts a photo by the person with the given game status" do
      create :photo, person: person, game_status: 'unfound'
      person.photo_count = 1
      expect(Person.photo_search_autocompletions(person.username, 'unfound')).to eq([autocompletion(person)])
    end

    it "ignores a photo by another person" do
      create :photo, game_status: 'unfound'
      expect(Person.photo_search_autocompletions(person.username, 'unfound')).to eq([])
    end

    it "ignores a photo with a different game status" do
      create :photo, game_status: 'found'
      expect(Person.photo_search_autocompletions(person.username, 'unfound')).to eq([])
    end

    def autocompletion(person)
      { value: person.username, label: person.photo_search_autocompletion_label }
    end

  end

  describe '#photo_search_autocompletion_label' do
    it "includes the username, real name and photo count" do
      person = build :person, photo_count: 1
      expect(person.photo_search_autocompletion_label).to eq("#{person.username} (#{person.realname}, 1)")
    end

    it "handles a missing real name" do
      person = build :person, realname: nil, photo_count: 1
      expect(person.photo_search_autocompletion_label).to eq("#{person.username} (1)")
    end

    it "ignores a real name which is the same as the username" do
      person = build :person, username: "the same", realname: "the same", photo_count: 1
      expect(person.photo_search_autocompletion_label).to eq("#{person.username} (1)")
    end

  end

end
