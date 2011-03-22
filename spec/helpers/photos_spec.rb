require 'spec_helper'

describe Photos do
  describe '#url_for_flickr_photo' do
    it "returns the URL to the given photo's Flickr page, in the GWSF pool" do
      photo = Photo.make
      url_for_flickr_photo(photo).should ==
        "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/";
    end
  end
end
