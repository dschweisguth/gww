class CronJob

  def self.update_from_flickr
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    new_photo_count, new_person_count, pages_gotten, pages_available = FlickrUpdate.create_before_and_update_after do
      Person.update_all_from_flickr
      Photo.update_all_from_flickr
    end
    PageCache.clear
    message = "Created #{new_photo_count} new photos and #{new_person_count} new users. " +
      "Got #{pages_gotten} pages out of #{pages_available}."
    puts message
    return message
  end

  def self.calculate_statistics_and_maps
    Person.update_statistics
    Photo.update_statistics
    Photo.infer_geocodes
    PageCache.clear
    message = "Updated statistics and maps."
    puts message
    return message
  end

end
