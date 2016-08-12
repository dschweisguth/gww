module PhotosPhotoSupport
  extend ActiveSupport::Concern
  include PhotoMapSupport

  module ClassMethods
    def unfound_or_unconfirmed
      where("game_status in ('unfound', 'unconfirmed')").order('lastupdate desc').includes(:person, :tags)
    end
  end

  def human_tags
    tags.reject &:machine_tag
  end

  def machine_tags
    tags.select &:machine_tag
  end

  def to_map_json
    if mapped_or_automapped?
      first_photo = self.class.oldest
      use_inferred_geocode_if_necessary
      prepare_for_map first_photo.dateadded
      to_json only: %i(id latitude longitude), methods: %i(color symbol)
    end
  end

end
