module GoogleMapsConfig
  private def google_maps_api_key
    @google_maps_api_key ||= YAML.load_file("#{Rails.root}/config/google_maps.yml")['api_key']
  end
end
