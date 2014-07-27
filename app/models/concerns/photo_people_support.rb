module PhotoPeopleSupport
  extend ActiveSupport::Concern
  include MultiPhotoMapSupport

  module ClassMethods
    def for_person_for_map(person_id, bounds, max_count)
      photos = posted_or_guessed_by_and_mapped person_id, bounds, max_count + 1 # TODO Dave move more code to this module
      partial = photos.length == max_count + 1
      if partial
        photos.to_a.pop
      end
      first_photo = Photo.oldest
      photos.each { |photo| photo.prepare_for_person_map person_id, first_photo.dateadded }
      as_map_json partial, bounds, photos
    end

  end

  def prepare_for_person_map(person_id, first_dateadded)
    use_inferred_geocode_if_necessary
    now = Time.now
    if person_id == self.person_id
      if %w(unfound unconfirmed).include? game_status
        self.color = 'FFFF00'
        self.symbol = '?'
      elsif game_status == 'found'
        self.color = Photo.scaled_blue first_dateadded, now, dateadded
        self.symbol = '?'
      else # revealed
        self.color = Photo.scaled_red first_dateadded, now, dateadded
        self.symbol = '-'
      end
    else
      self.color = Photo.scaled_green first_dateadded, now, dateadded
      self.symbol = '!'
    end
  end

end
