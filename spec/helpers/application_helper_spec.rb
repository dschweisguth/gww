describe ApplicationHelper do
  describe '#singularize' do
    it "replaces a plural verb with a singular one" do
      expect(helper.singularize('delete', 1)).to eq('deletes')
    end

    it "leaves the verb alone if the number is other than 1" do
      expect(helper.singularize('delete', 0)).to eq('delete')
    end

    expected = { 'are' => 'is', 'were' => 'was', 'have' => 'has' }
    expected.each_key do |plural|
      it "singularizes the irregular plural verb #{plural} to #{expected[plural]}" do
        expect(helper.singularize(plural, 1)).to eq(expected[plural])
      end
    end

  end

  describe '#local_date' do
    it "returns the local time as yyyy/mm/dd" do
      expect(helper.local_date(Time.utc(2011))).to eq('2010/12/31')
    end
  end

  describe '#link_to_person' do
    it "returns a local link to the person" do
      person = build_stubbed :person
      expect(helper.link_to_person(person)).to eq("<a href=\"#{person_path person}\">#{person.username}</a>")
    end

    it "escapes HTML special characters in the username" do
      person = build_stubbed :person, username: 'tom&jerry'
      expect(helper.link_to_person(person)).to eq("<a href=\"#{person_path person}\">tom&amp;jerry</a>")
    end

  end

  describe '#link_to_photo' do
    it "returns a local link to the photo" do
      photo = build_stubbed :person
      expect(helper.link_to_photo(photo)).to eq(%Q(<a href="/photos/#{photo.id}">GWW</a>))
    end
  end

  describe '#link_to_flickr_photo' do
    it "returns a link to the given photo's Flickr page, in the GWSF pool" do
      photo = build_stubbed :photo
      expect(helper.link_to_flickr_photo(photo)).to eq(
        "<a href=\"#{url_for_flickr_photo_in_pool photo}\">Flickr</a>"
      )
    end
  end

  describe '#titled_image_tag' do
    it "returns an image tag with alt and title attributes set to the given value" do
      expect(helper.titled_image_tag('http://the.url', 'the title')).to eq(
        '<img alt="the title" title="the title" src="http://the.url" />'
      )
    end

    it "handles additional attributes" do
      expect(helper.titled_image_tag('http://the.url', 'the title', additional: 'foo')).to eq(
        '<img alt="the title" title="the title" additional="foo" src="http://the.url" />'
      )
    end

  end

  describe '#thumbnail' do
    before do
      @photo = build_stubbed :photo
    end

    it "returns a photo's thumbnail with empty alt and title wrapped in a link to the photo's page" do
      expect(helper.thumbnail(@photo)).to eq(
        %Q(<a href="#{photo_path @photo}"><img alt="" title="" src="#{url_for_flickr_image @photo, 't'}" /></a>)
      )
    end

    it "returns a photo's thumbnail with non-empty alt and title wrapped in a link to the photo's page" do
      expect(helper.thumbnail(@photo, "alt text")).to eq(
        %Q(<a href="#{photo_path @photo}"><img alt="alt text" title="alt text" src="#{url_for_flickr_image @photo, 't'}" /></a>)
      )
    end

  end

  describe '#head_css' do
    it "adds the given stylesheets to the head" do
      helper.head_css 'my.css'
      expect(helper.content_for(:head)).to include 'my.css'
    end
  end

  describe '#head_javascript' do
    it "adds the default Javascript includes and the CSRF protection data to the head" do
      helper.head_javascript
      content_for_head = helper.content_for(:head)
      expect(content_for_head).to match /application-\w+.js/
      # Can't test that CSRF stuff is present since test controller doesn't have protect_from_forgery
    end

    it "adds additional Javascript includes to the head" do
      helper.head_javascript 'my.js'
      expect(helper.content_for(:head)).to include 'my.js'
    end

  end

  describe '#title_and_h1' do
    it "adds the title to the head and emits an h1 with the same text" do
      fragment = helper.title_and_h1 'foo'
      expect(fragment).to have_css 'h1', text: 'foo'
      expect(helper.content_for(:title)).to eq('foo')
    end
  end

end
