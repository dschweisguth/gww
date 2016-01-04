describe Updater do
  include GWW::Helpers::PageCache

  describe '#update' do
    it "does some work" do
      mock_clear_page_cache 2
      allow(FlickrService.instance).to receive(:groups_get_info).with(group_id: FlickrService::GROUP_ID) do
        {
          'group' => [{
            'members' => ['1492']
          }]
        }
      end
      expect(PhotoUpdater).to receive(:update_all) { [ 1, 2, 3, 4 ] }
      expect(PersonUpdater).to receive(:update_all)
      allow(Time).to receive(:now) { Time.utc(2011) }
      expect(Updater.update).to eq("Created 1 new photos and 2 new users. Got 3 pages out of 4.")
      update = FlickrUpdate.first_and_only
      expect(update.member_count).to eq(1492)
      expect(update.completed_at).to eq(Time.utc(2011))
    end
  end

end
