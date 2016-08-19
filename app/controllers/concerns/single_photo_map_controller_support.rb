module SinglePhotoMapControllerSupport
  include MapControllerSupport

  private def add_map_photo_to_page_config
    map_json = @photo.as_map_json
    if map_json
      add_map_data_to_page_config photo: map_json
    end
  end

end
