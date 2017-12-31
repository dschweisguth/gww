describe ScoreReportsHelper do
  describe '#escape_username' do
    it "surrounds the dot in a username that looks like a domain name with spaces" do
      expect(helper.escape_username('m.bibelot')).to eq('m . bibelot')
    end

    it "does so regardless of capitalization" do
      expect(helper.escape_username('KayVee.INC')).to eq('KayVee . INC')
    end

    it "does nothing if the dot is preceded by a space" do
      expect(helper.escape_username('KayVee .INC')).to eq('KayVee .INC')
    end

    it "does nothing if the dot is followed by a space" do
      expect(helper.escape_username('KayVee. INC')).to eq('KayVee. INC')
    end

  end

  describe '#link_to_person_url' do
    it "returns a fully qualified link to the person's page" do
      person = build_stubbed :person
      expect(helper.link_to_person_url(person)).to eq("<a href=\"#{person_url person}\">#{person.username}</a>")
    end

    it "escapes HTML special characters in the person's username" do
      person = build_stubbed :person, username: 'try&catch>me'
      expect(helper.link_to_person_url(person)).to eq("<a href=\"#{person_url person}\">try&amp;catch&gt;me</a>")
    end

  end

  describe '#image_url_for_star' do
    expected = {
      bronze: 'https://farm9.staticflickr.com/8332/8143796058_095478b380_o.gif',
      silver: 'https://farm9.staticflickr.com/8470/8143764201_c938bf6bea_o.gif',
      gold:   'https://farm9.staticflickr.com/8050/8143796020_85a314ced3_o.gif'
    }
    expected.each_key do |star|
      it "returns #{expected[star]} given a #{star} star" do
        expect(helper.image_url_for_star(star)).to eq(expected[star])
      end
    end
  end

end
