describe Admin::RootController do
  render_views

  describe '#index' do
    it "renders the page" do
      allow(FlickrUpdate).to receive(:latest) { build_stubbed :flickr_update, created_at: Time.local(2011) }
      allow(Photo).to receive(:unfound_or_unconfirmed_count) { 111 }
      allow(Photo).to receive(:inaccessible_count) { 222 }
      allow(Photo).to receive(:multipoint_count) { 2 }
      get :index

      response.should be_success
      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and is still running. An update takes about 40 minutes.'
      response.body.should include '(111)'
      response.body.should include '(222)'
      response.body.should include '(2)'

    end

    it "reports a completed update" do
      allow(FlickrUpdate).to receive(:latest) do
        build_stubbed :flickr_update, created_at: Time.local(2011), completed_at: Time.local(2001, 1, 1, 0, 6)
      end
      allow(Photo).to receive(:unfound_or_unconfirmed_count) { 111 }
      allow(Photo).to receive(:inaccessible_count) { 222 }
      allow(Photo).to receive(:multipoint_count) { 2 }
      get :index

      response.body.should include 'The most recent update from Flickr began Saturday, January  1,  0:00 PST and completed at Monday, January  1,  0:06 PST.'

    end

  end

  describe '#update_from_flickr' do
    it "does the update and redirects" do
      expect(FlickrUpdater).to receive(:update_everything) { "The message" }
      get :update_from_flickr
      response.should redirect_to admin_root_path
      flash[:notice].should == "The message"
    end
  end

  describe '#calculate_statistics_and_maps' do
    it "does the update and redirects" do
      expect(Precalculator).to receive(:calculate_statistics_and_maps) { "The message" }
      get :calculate_statistics_and_maps
      response.should redirect_to admin_root_path
      flash[:notice].should == "The message"
    end
  end

  describe '#bookmarklet' do
    it "renders the page" do
      get :bookmarklet

      response.should be_success
      response.body.should have_css %Q(a[href="#{root_bookmarklet_path}"])

    end
  end

end
