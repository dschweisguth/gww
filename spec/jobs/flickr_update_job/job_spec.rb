describe FlickrUpdateJob::Job do
  include GWW::Helpers::PageCache

  describe '#update' do
    it "does some work" do
      allow(FlickrService.instance).to receive(:groups_get_info).with(group_id: FlickrService::GROUP_ID).and_return({
        'group' => [{
          'members' => ['1492']
        }]
      })
      allow(FlickrUpdateJob::PhotoUpdater).to receive(:update_all).and_return([1, 2, 3, 4])
      allow(FlickrUpdateJob::PersonUpdater).to receive(:update_all)
      allow(Time).to receive(:now) { Time.utc(2011) }
      allow_clear_page_cache
      message = FlickrUpdateJob::Job.run

      expect(message).to eq("Created 1 new photos and 2 new users. Got 3 pages out of 4.")
      expect(FlickrUpdateJob::PhotoUpdater).to have_received(:update_all)
      expect(FlickrUpdateJob::PersonUpdater).to have_received(:update_all)
      update = FlickrUpdate.first_and_only
      expect(update.member_count).to eq(1492)
      expect(update.completed_at).to eq(Time.utc(2011))
      expect_clear_page_cache 2
    end

  end

end
