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
    color, symbol =
      if person_id == self.person_id
        if %w(unfound unconfirmed).include? game_status
          [Color::Yellow, '?']
        elsif game_status == 'found'
          [Color::Blue, '?']
        else # revealed
          [Color::Red, '-']
        end
      else
        [Color::Green, '!']
      end
    self.color = color.scaled first_dateadded, Time.now, dateadded
    self.symbol = symbol
  end

end
