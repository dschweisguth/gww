require 'spec_helper'

describe FlickrCredentials do
  describe '.request' do
    before do
      FlickrCredentials.retry_quantum = 0.001
    end

    it 'sends a request to the Flickr API' do
      request_should_succeed
    end

    it 'retries a failed request once' do
      mock_get_fails 1
      mock_get_succeeds
      request_should_succeed
    end

    it 'retries a failed request thrice' do
      mock_get_fails 3
      mock_get_succeeds
      request_should_succeed
    end

    it 'gives up after four failures' do
      mock_get_fails 4
      lambda { FlickrCredentials.request 'flickr.people.findByUsername',
        'username' => 'dschweisguth' }.should raise_error StandardError
    end

    def mock_get_fails(times)
      Net::HTTP.should_receive(:get_response).exactly(times).ordered.and_raise(StandardError)
    end

    def mock_get_succeeds
      response = mock("response")
      response.stub!(:body).and_return('<rsp>\n<user nsid="26686665@N06"/></rsp>')
      Net::HTTP.should_receive(:get_response).once.ordered.and_return(response)
    end

    def request_should_succeed
      result = FlickrCredentials.request 'flickr.people.findByUsername',
        'username' => 'dschweisguth'
      result['user'][0]['nsid'].should == '26686665@N06'
    end

  end
end
