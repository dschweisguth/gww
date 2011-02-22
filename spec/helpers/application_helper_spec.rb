require 'spec_helper'
require 'support/model_factory'

describe ApplicationHelper do
  describe '#singularize' do
    it 'replaces a plural verb with a singular one' do
      helper.singularize('delete', 1).should == 'deletes'
    end

    it 'leaves the verb alone if the number is other than 1' do
      helper.singularize('delete', 0).should == 'delete'
    end

    expected = { 'were' => 'was', 'have' => 'has' }
    expected.keys.each do |plural|
      it "singularizes the irregular plural verb #{plural} to #{expected[plural]}" do
        helper.singularize(plural, 1).should == expected[plural]
      end
    end

  end

  describe '#ordinal' do
    expected = {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      11 => '11th',
      12 => '12th',
      13 => '13th',
      21 => '21st',
      22 => '22nd',
      23 => '23rd'
    }
    expected.keys.sort.each do |cardinal|
      it "converts the number #{cardinal} to its ordinal, #{expected[cardinal]}" do
        helper.ordinal(cardinal).should == expected[cardinal]
      end
    end
  end

  describe '#local_date' do
    it 'returns the local time as yyyy/mm/dd' do
      helper.local_date(Time.utc(2011)).should == '2010/12/31'
    end
  end

  describe '#link_to_person' do
    it 'returns a local link to the person' do
      person = Person.make
      stub(person).id { 666 }
      helper.link_to_person(person).should == '<a href="/people/show/666">username</a>'
    end

    it 'escapes HTML special characters in the username' do
      person = Person.make :username => 'tom&jerry'
      stub(person).id { 666 }
      helper.link_to_person(person).should == '<a href="/people/show/666">tom&amp;jerry</a>'
    end

  end

  describe '#link_to_photo' do
    it 'returns a local link to the photo' do
      photo = Photo.make
      stub(photo).id { 666 }
      helper.link_to_photo(photo).should == '<a href="/photos/show/666">GWW</a>'
    end
  end

  describe '#url_for_flickr_photo' do
    it "returns the URL to the given photo's Flickr page, in the GWSF pool" do
      photo = Photo.make
      helper.url_for_flickr_photo(photo).should ==
        "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/";
    end
  end

  describe '#link_to_flickr_photo' do
    it "returns a link to the given photo's Flickr page, in the GWSF pool" do
      photo = Photo.make
      helper.link_to_flickr_photo(photo).should ==
        "<a href=\"http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/\">Flickr</a>";
    end
  end

  describe '#url_for_flickr_image' do
    it 'returns the URL to the given photo' do
      photo = Photo.make :farm => '0'
      helper.url_for_flickr_image(photo, nil).should ==
        'http://farm0.static.flickr.com/server/photo_flickrid_secret.jpg';
    end

    it 'handles missing farm' do
      photo = Photo.make :farm => ''
      helper.url_for_flickr_image(photo, nil).should ==
        'http://static.flickr.com/server/photo_flickrid_secret.jpg';
    end

    it 'provides the requested size' do
      photo = Photo.make! :farm => '0'
      helper.url_for_flickr_image(photo, 't').should ==
        'http://farm0.static.flickr.com/server/photo_flickrid_secret_t.jpg';
    end

  end

  describe '#titled_image_tag' do
    it 'returns an image tag with alt and title attributes set to the given value' do
      helper.titled_image_tag('http://the.url', 'the title').should ==
        '<img alt="the title" src="http://the.url" title="the title" />'
    end

    it 'handles additional attributes' do
      helper.titled_image_tag('http://the.url', 'the title', :additional => 'foo').should ==
        '<img additional="foo" alt="the title" src="http://the.url" title="the title" />'
    end

  end

  describe '#thumbnail' do
    before do
      @photo = Photo.make
      stub(@photo).id { 666 }
    end

    it "returns an photo's thumbnail with empty alt and title wrapped in a link to the photo's page" do
      helper.thumbnail(@photo).should ==
        '<a href="/photos/show/666"><img alt="" src="http://farm0.static.flickr.com/server/photo_flickrid_secret_t.jpg" title="" /></a>'
    end

    it "returns an photo's thumbnail with empty alt and title wrapped in a link to the photo's page" do
      helper.thumbnail(@photo, "alt text").should ==
        '<a href="/photos/show/666"><img alt="alt text" src="http://farm0.static.flickr.com/server/photo_flickrid_secret_t.jpg" title="alt text" /></a>'
    end

  end

  describe '#sandwich' do
    it "wraps the given content in views/shared/_sandwich " +
      "(which can't be tested due to the lack of rspec support, discussed here http://www.ruby-forum.com/topic/188667)"
  end

end
