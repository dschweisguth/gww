module PhotoPeopleSupport
  extend ActiveSupport::Concern
  include MultiPhotoMapSupport

  module ClassMethods
    def for_person_for_map(person_id, bounds, max_count)
      photos = posted_or_guessed_by_and_mapped person_id, bounds, max_count + 1
      partial = photos.length == max_count + 1
      if partial
        photos.to_a.pop
      end
      first_photo = Photo.oldest
      photos.each { |photo| photo.prepare_for_person_map person_id, first_photo.dateadded }
      as_map_json partial, bounds, photos
    end

    def posted_or_guessed_by_and_mapped(person_id, bounds, limit)
      mapped(bounds, limit)
        .joins('left join guesses on guesses.photo_id = photos.id')
        .where('photos.person_id = ? or guesses.person_id = ?', person_id, person_id)
    end

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

  def ymd_elapsed
    ymd_elapsed_between dateadded, Time.now
  end

  def star_for_comments
    if other_user_comments >= 30
      :gold
    elsif other_user_comments >= 20
      :silver
    else
      nil
    end
  end

  def star_for_views
    if views >= 3000
      :gold
    elsif views >= 1000
      :silver
    elsif views >= 300
      :bronze
    else
      nil
    end
  end

  def star_for_faves
    if faves >= 100
      :gold
    elsif faves >= 30
      :silver
    elsif faves >= 10
      :bronze
    else
      nil
    end
  end

  def has_obsolete_tags?
    if %w(found revealed).include?(game_status)
      raws = tags.map { |tag| tag.raw.downcase }
      raws.include?('unfoundinsf') &&
        ! (raws.include?('foundinsf') || game_status == 'revealed' && raws.include?('revealedinsf'))
    end
  end

end
