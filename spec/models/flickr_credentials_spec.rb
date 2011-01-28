require 'spec_helper'

describe FlickrCredentials do
  describe '.request' do
    it 'sends a request to the Flickr API' do
      result = FlickrCredentials.request 'flickr.people.findByUsername',
        'username' => 'dschweisguth'
      result['user'][0]['nsid'].should == '26686665@N06'
    end

    it 'retries' do
      FlickrCredentials.retry_quantum = 0.001
      Net::HTTP.should_receive(:get_response).once.ordered.and_raise(StandardError)
      response = mock("response")
      response.stub!(:body).and_return('<rsp>\n<user nsid="26686665@N06"/></rsp>')
      Net::HTTP.should_receive(:get_response).once.ordered.and_return(response)
      result = FlickrCredentials.request 'flickr.people.findByUsername',
        'username' => 'dschweisguth'
      result['user'][0]['nsid'].should == '26686665@N06'
    end

  end
end
