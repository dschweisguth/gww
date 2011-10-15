require 'spec_helper'

describe ApplicationHelper do

  describe '#singularize' do
    it 'replaces a plural verb with a singular one' do
      helper.singularize('delete', 1).should == 'deletes'
    end

    it 'leaves the verb alone if the number is other than 1' do
      helper.singularize('delete', 0).should == 'delete'
    end

    expected = { 'are' => 'is', 'were' => 'was', 'have' => 'has' }
    expected.keys.each do |plural|
      it "singularizes the irregular plural verb #{plural} to #{expected[plural]}" do
        helper.singularize(plural, 1).should == expected[plural]
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
      helper.link_to_person(person).should == "<a href=\"#{person_path person}\">#{person.username}</a>"
    end

    it 'escapes HTML special characters in the username' do
      person = Person.make :username => 'tom&jerry'
      helper.link_to_person(person).should == "<a href=\"#{person_path person}\">tom&amp;jerry</a>"
    end

  end

  describe '#link_to_photo' do
    it 'returns a local link to the photo' do
      photo = Photo.make :id => 666
      helper.link_to_photo(photo).should == '<a href="/photos/666">GWW</a>'
    end
  end

  describe '#link_to_flickr_photo' do
    it "returns a link to the given photo's Flickr page, in the GWSF pool" do
      photo = Photo.make
      helper.link_to_flickr_photo(photo).should ==
        "<a href=\"#{url_for_flickr_photo_in_pool photo}\">Flickr</a>";
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
      @photo = Photo.make :id => 666
    end

    it "returns a photo's thumbnail with empty alt and title wrapped in a link to the photo's page" do
      helper.thumbnail(@photo).should ==
        %Q{<a href="#{photo_path @photo}"><img alt="" src="#{url_for_flickr_image @photo, 't'}" title="" /></a>}
    end

    it "returns a photo's thumbnail with non-empty alt and title wrapped in a link to the photo's page" do
      helper.thumbnail(@photo, "alt text").should ==
        %Q{<a href="#{photo_path @photo}"><img alt="alt text" src="#{url_for_flickr_image @photo, 't'}" title="alt text" /></a>}
    end

  end

  describe '#sandwich' do
    it "wraps the given content in views/shared/_sandwich " +
      "(which can't be tested due to the lack of rspec support, discussed here http://www.ruby-forum.com/topic/188667)"
  end

  describe '#head_css' do
    it "adds the given stylesheets to the head" do
      helper.head_css 'my.css'
      helper.content_for(:head).should include 'my.css'
    end
  end

  describe '#head_javascript' do
    it "adds the default Javascript includes and the CSRF protection data to the head" do
      helper.head_javascript
      content_for_head = helper.content_for(:head)
      content_for_head.should include 'jquery.min.js'
      content_for_head.should include 'jquery_ujs.js'
      # Can't test that CSRF stuff is present since test controller doesn't have protect_from_forgery
    end

    it "adds additional Javascript includes to the head" do
      helper.head_javascript 'my.js'
      helper.content_for(:head).should include 'my.js'
    end

  end

  describe '#title_and_h1' do
    it "adds the title to the head and emits an h1 with the same text" do
      fragment = helper.title_and_h1 'foo'
      fragment.should have_selector 'h1', :content => 'foo';
      helper.content_for(:title).should == 'foo'
    end
  end

end
