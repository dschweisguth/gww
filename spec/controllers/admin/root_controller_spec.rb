describe Admin::RootController do
  describe '#index' do
    let(:now) { Time.local(2011) }

    it "renders the page" do
      allow(FlickrUpdate).to receive(:latest).and_return(build_stubbed :flickr_update, created_at: now)
      allow(AdminRootPhoto).to receive(:unfound_or_unconfirmed_count).and_return(111)
      allow(AdminRootPhoto).to receive(:inaccessible_count).and_return(222)
      allow(AdminRootPhoto).to receive(:multipoint_count).and_return(2)
      get :index

      expect(response).to be_success
      expect(response.body).to include "The most recent update from Flickr began Saturday, January  1,  0:00 #{now.zone} and is still running. An update takes about an hour."
      expect(response.body).to include '(111)'
      expect(response.body).to include '(222)'
      expect(response.body).to include '(2)'
    end

    it "reports a completed update" do
      allow(FlickrUpdate).to receive(:latest).
        and_return(build_stubbed(:flickr_update, created_at: now, completed_at: Time.local(2001, 1, 1, 0, 6)))
      allow(AdminRootPhoto).to receive(:unfound_or_unconfirmed_count).and_return(111)
      allow(AdminRootPhoto).to receive(:inaccessible_count).and_return(222)
      allow(AdminRootPhoto).to receive(:multipoint_count).and_return(2)
      get :index

      expect(response.body).to include "The most recent update from Flickr began Saturday, January  1,  0:00 #{now.zone} and completed at Monday, January  1,  0:06 #{now.zone}."
    end

  end

  describe '#update_from_flickr' do
    it "does the update and redirects" do
      allow(FlickrUpdateJob::Job).to receive(:run).and_return("The message")
      get :update_from_flickr

      expect(FlickrUpdateJob::Job).to have_received(:run)
      expect(response).to redirect_to admin_root_path
      expect(flash[:notice]).to eq("The message")
    end
  end

  describe '#calculate_statistics_and_maps' do
    it "does the update and redirects" do
      allow(PrecalculatorJob::Job).to receive(:run).and_return("The message")
      get :calculate_statistics_and_maps

      expect(PrecalculatorJob::Job).to have_received(:run)
      expect(response).to redirect_to admin_root_path
      expect(flash[:notice]).to eq("The message")
    end
  end

  describe '#bookmarklet' do
    it "renders the page" do
      get :bookmarklet

      expect(response).to be_success
      expect(response.body).to have_css %Q(a[href="#{root_bookmarklet_path}"])
    end
  end
end
