require 'spec_helper'

describe Photos do

  describe '#url_for_flickr_photo' do
    it "returns the URL to the given photo's Flickr page" do
      photo = Photo.make
      photo.person.pathalias = "poster_pathalias"
      url_for_flickr_photo(photo).should ==
        "http://www.flickr.com/photos/#{photo.person.pathalias}/#{photo.flickrid}/";
    end

    it "falls back on the poster's flickrid if they have no pathalias" do
      photo = Photo.make
      url_for_flickr_photo(photo).should ==
        "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/";
    end

  end

  describe '#url_for_flickr_photo_in_pool' do
    it "returns the URL to the given photo's Flickr page, in the GWSF pool" do
      photo = Photo.make
      url_for_flickr_photo_in_pool(photo).should ==
        "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/";
    end
  end

  describe '#url_for_flickr_image' do
    it 'returns the URL to the given photo' do
      photo = Photo.make
      url_for_flickr_image(photo).should ==
        "http://farm#{photo.farm}.static.flickr.com/server/#{photo.flickrid}_#{photo.secret}.jpg";
    end

    it 'handles missing farm' do
      photo = Photo.make farm: ''
      url_for_flickr_image(photo).should ==
        "http://static.flickr.com/server/#{photo.flickrid}_#{photo.secret}.jpg";
    end

    it 'provides the requested size' do
      photo = Photo.make
      url_for_flickr_image(photo, 't').should ==
        "http://farm0.static.flickr.com/server/#{photo.flickrid}_#{photo.secret}_t.jpg";
    end

  end

end
