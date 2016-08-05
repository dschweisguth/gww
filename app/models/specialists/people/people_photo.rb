class PeoplePhoto < Photo
  include MultiPhotoMapSupport

  belongs_to :person, inverse_of: :photos, class_name: 'PeoplePerson', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :photo, dependent: :destroy, class_name: 'PeopleGuess', foreign_key: 'photo_id'

  def self.for_person_for_map(person_id, bounds, max_count)
    photos = posted_or_guessed_by_and_mapped person_id, bounds, max_count + 1
    partial = photos.length == max_count + 1
    if partial
      photos.to_a.pop
    end
    first_photo = oldest
    photos.each { |photo| photo.prepare_for_person_map person_id, first_photo.dateadded }
    as_map_json partial, bounds, photos
  end

  def self.posted_or_guessed_by_and_mapped(person_id, bounds, limit)
    mapped(bounds, limit).
      joins('left join guesses on guesses.photo_id = photos.id').
      where('photos.person_id = ? or guesses.person_id = ?', person_id, person_id)
  end

  def prepare_for_person_map(person_id, first_dateadded)
    use_inferred_geocode_if_necessary
    color, symbol =
      if person_id == self.person_id
        case game_status
          when 'unfound', 'unconfirmed'
            [Color::Yellow, '?']
          when 'found'
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
