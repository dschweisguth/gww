require 'spec_helper'

describe FlickrCredentials do
  describe '.request' do
    before do
      FlickrCredentials.retry_quantum = 0.001
    end

    it 'sends a request to the Flickr API' do
      request_succeeds
    end

    it 'raises an error if stat != ok' do
      mock_get_returns '<rsp stat="fail"><err code="1" msg="User not found"/></rsp>'
      lambda { FlickrCredentials.request 'flickr.people.findByUsername', 'username' => 'dschweisguth' }.should raise_error FlickrCredentials::FlickrRequestFailedError
    end

    it 'retries a failed request once' do
      mock_get_times_out 1
      mock_get_succeeds
      request_succeeds
    end

    it 'retries a failed request thrice' do
      mock_get_times_out 3
      mock_get_succeeds
      request_succeeds
    end

    it 'gives up after four failures' do
      mock_get_times_out 4
      lambda { FlickrCredentials.request 'flickr.people.findByUsername', 'username' => 'dschweisguth' }.should raise_error FlickrCredentials::FlickrRequestFailedError
    end

    def mock_get_times_out(times)
      mock(Net::HTTP).get_response.with_any_args.times(times) { raise Timeout::Error }
    end

    def mock_get_succeeds
      mock_get_returns '<rsp stat="ok"><user nsid="26686665@N06"/></rsp>'
    end

    def mock_get_returns(body)
      response = Object.new
      mock(response).body { body }
      mock(Net::HTTP).get_response.with_any_args { response }
    end

    def request_succeeds
      result = FlickrCredentials.request 'flickr.people.findByUsername', 'username' => 'dschweisguth'
      result['user'][0]['nsid'].should == '26686665@N06'
    end

  end
end
