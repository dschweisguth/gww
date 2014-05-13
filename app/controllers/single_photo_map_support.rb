module SinglePhotoMapSupport
  include MapSupport

  private def set_config_to(photo)
    if photo.mapped_or_automapped?
      first_photo = Photo.oldest
      use_inferred_geocode_if_necessary [ photo ]
      prepare_for_display photo, first_photo.dateadded
      @json = photo.to_json only: %i(id latitude longitude), methods: %i(color symbol)
    end
  end

end
