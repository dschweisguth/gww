describe RootController do
  describe '#index' do
    let(:now) { Time.local(2011) }

    it "renders the page" do
      allow(FlickrUpdate).to receive(:latest).and_return(build_stubbed :flickr_update, created_at: now.getutc)
      allow(ScoreReport).to receive(:minimum).and_return(now.getutc)
      get :index

      expect(response).to be_success
      expect(response.body).to include "The most recent update from Flickr began Saturday, January  1,  0:00 #{now.zone} and is still running. An update takes about an hour."

    end

    it "reports a completed update" do
      allow(FlickrUpdate).to receive(:latest).and_return(build_stubbed :flickr_update, created_at: now, completed_at: Time.local(2001, 1, 1, 0, 6))
      allow(ScoreReport).to receive(:minimum).and_return(now.getutc)
      get :index

      expect(response).to be_success
      expect(response.body).to include "The most recent update from Flickr began Saturday, January  1,  0:00 #{now.zone} and completed at Monday, January  1,  0:06 #{now.zone}."

    end

  end
end
