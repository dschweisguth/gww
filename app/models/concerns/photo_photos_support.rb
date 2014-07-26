module PhotoPhotosSupport
  extend ActiveSupport::Concern
  include MultiPhotoMapSupport

  module ClassMethods

    def all_for_map(bounds, max_count)
      photos = mapped bounds, max_count + 1
      partial = photos.length == max_count + 1
      if partial
        photos.to_a.pop
      end
      first_photo = oldest
      if first_photo
        photos.each { |photo| photo.prepare_for_map first_photo.dateadded }
      end
      as_map_json partial, bounds, photos
    end

  end

end
