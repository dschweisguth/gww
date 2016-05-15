describe PersonPhotosSupport do
  describe '.photo_search_autocompletion_label' do
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
