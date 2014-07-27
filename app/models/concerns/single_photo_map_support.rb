module SinglePhotoMapSupport
  extend ActiveSupport::Concern # so if we're the first to include the parent its ClassMethods are included too
  include PhotoMapSupport

  def to_map_json
    if mapped_or_automapped?
      first_photo = Photo.oldest
      use_inferred_geocode_if_necessary
      prepare_for_map first_photo.dateadded
      to_json only: %i(id latitude longitude), methods: %i(color symbol)
    end
  end

end
