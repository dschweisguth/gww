class Updater
  def self.update
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    group_info = FlickrService.instance.groups_get_info group_id: FlickrService::GROUP_ID
    member_count = group_info['group'][0]['members'][0]
    update = FlickrUpdate.create! member_count: member_count
    PersonUpdater.update_all
    new_photo_count, new_person_count, pages_gotten, pages_available = PhotoUpdater.update_all
    update.update! completed_at: Time.now.getutc
    PageCache.clear
    "Created #{new_photo_count} new photos and #{new_person_count} new users. Got #{pages_gotten} pages out of #{pages_available}."
  end
end
