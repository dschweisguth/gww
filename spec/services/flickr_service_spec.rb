describe FlickrService, type: :service do
  let(:service) { FlickrService.new }

  before do
    service.retry_quantum = 0.001
  end

  describe '.groups_get_info' do
    it "gets group info" do
      expect(service.groups_get_info(group_id: FlickrService::GROUP_ID)['group'][0]['id']).to eq(FlickrService::GROUP_ID)
    end
  end

  describe '.groups_pools_get_photos' do
    it "gets group photos" do
      expect(service.groups_pools_get_photos('group_id' => FlickrService::GROUP_ID)['photos']).not_to be_empty
    end
  end

  describe '.people_get_info' do
    it "gets people info" do
      expect(service.people_get_info('user_id' => '26686665@N06')['person'][0]['id']).to eq('26686665@N06')
    end
  end

  describe '.photos_get_favorites' do
    it "gets a photo's favorites" do
      expect(service.photos_get_favorites('photo_id' => '4637739576')['photo'][0]['person']).not_to be_empty
    end
  end

  describe '.photos_get_info' do
    it "gets a photo's info" do
      expect(service.photos_get_info('photo_id' => '4637739576')['photo'][0]['id']).to eq('4637739576')
    end
  end

  describe '.photos_comments_get_list' do
    it "gets a photo's comments" do
      expect(service.photos_comments_get_list('photo_id' => '4637739576')['comments'][0]['comment']).not_to be_empty
    end
  end

  describe '.photos_geo_get_location' do
    it "gets a photo's location" do
      expect(service.photos_geo_get_location('photo_id' => '4132399939')['photo'][0]['location']).not_to be_empty
    end
  end

  describe '.tags_get_list_photo' do
    it "gets a photo's tags" do
      expect(service.tags_get_list_photo('photo_id' => '4637739576')['photo'][0]['tags'][0]['tag']).not_to be_empty
    end
  end

  describe '.request' do

    it "sends a request to the Flickr API" do
      request_succeeds
    end

    it "raises an error if the response is not XML, such as when there's an OAuth problem" do
      mock_get_returns "oauth_problem=signature_invalid"
      request_fails
    end

    it "raises an error if stat != ok" do
      mock_get_returns '<rsp stat="fail"><err code="1" msg="User not found"/></rsp>'
      request_fails
    end

    it "retries a failed request once" do
      mock_get_times_out 1
      mock_get_succeeds
      request_succeeds
    end

    it "retries a failed request thrice" do
      mock_get_times_out 3
      mock_get_succeeds
      request_succeeds
    end

    it "gives up after four failures" do
      mock_get_times_out 4
      request_fails
    end

    it "accepts non-string option names" do
      expect(service.request('flickr.groups.pools.getPhotos', 'group_id' => FlickrService::GROUP_ID, per_page: '1')['photos']).not_to be_empty
    end

    it "accepts non-string option values" do
      expect(service.request('flickr.groups.pools.getPhotos', group_id: FlickrService::GROUP_ID, per_page: 1)['photos']).not_to be_empty
    end

    def request_succeeds
      # At least some of the Flickr API methods that GWW uses don't require OAuth, or work (perhaps returning less
      # information) when a request is not signed or is signed incorrectly. flickr.test.login requires correct OAuth to
      # work at all, so use it in these tests to verify that our OAuth implementation is correct.
      result = service.request 'flickr.test.login'
      expect(result['user'][0]['username'][0]).to eq('dschweisguth')
    end

    def request_fails
      expect { service.request 'flickr.test.login' }.to raise_error FlickrService::FlickrRequestFailedError
    end

    def mock_get_times_out(times)
      expect(service).to receive(:get).exactly(times).times { raise Timeout::Error }
    end

    def mock_get_succeeds
      mock_get_returns '<?xml version="1.0" encoding="utf-8" ?><rsp stat="ok"><user id="26686665@N06"><username>dschweisguth</username></user></rsp>'
    end

    def mock_get_returns(body)
      response = Object.new
      expect(response).to receive(:body) { body }
      expect(service).to receive(:get) { response }
    end

  end

  describe '.seconds_to_wait' do

    it "returns 0 in tests" do
      expect(service.seconds_to_wait).to eq(0)
    end

    context "when not in tests" do
      before do
        allow(Rails.env).to receive(:test?) { false }
      end

      it "returns 0 the first time it's called" do
        expect(service.seconds_to_wait).to eq(0)
      end

      it "returns 1 if it's been 0 seconds since it was last called" do
        allow(Time).to receive(:now) { Time.utc(2014) }
        service.seconds_to_wait
        expect(service.seconds_to_wait).to eq(1)
      end

      it "returns 0.25 if it's been 0.75 seconds since it was last called" do
        allow(Time).to receive(:now) { Time.utc(2014) }
        service.seconds_to_wait
        allow(Time).to receive(:now) { Time.utc(2014) + 0.75.seconds }
        expect(service.seconds_to_wait).to eq(0.25)
      end

      it "returns 0 if it's been more than 1 second since it was last called" do
        allow(Time).to receive(:now) { Time.utc(2014) }
        service.seconds_to_wait
        allow(Time).to receive(:now) { Time.utc(2014) + 2.seconds }
        expect(service.seconds_to_wait).to eq(0)
      end

    end

  end

end
