module SinglePhotoMapSupport
  include MapSupport

  def set_config_to(photo)
    if photo.mapped_or_automapped?
      first_photo = Photo.oldest
      use_inferred_geocode_if_necessary [ photo ]
      prepare_for_display photo, first_photo.dateadded
      @json = photo.to_json :only => [ :id, :latitude, :longitude, :color, :symbol ]
    else
      @json = '{}'
    end
  end
  private :set_config_to

end
