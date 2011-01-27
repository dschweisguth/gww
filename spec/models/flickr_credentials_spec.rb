require 'spec_helper'

describe FlickrCredentials do
  describe '.request' do
    it 'sends a requst to the Flickr API' do
      result = FlickrCredentials.request 'flickr.people.findByUsername',
        'username' => 'dschweisguth'
      result['user'][0]['nsid'].should == '26686665@N06'
    end
  end
end
