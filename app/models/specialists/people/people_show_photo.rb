class PeopleShowPhoto < Photo
  include PhotoScoreSupport, ScoreSupport

  belongs_to :person, inverse_of: :photos, class_name: 'PeopleShowPerson', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :photo, dependent: :destroy, class_name: 'PeopleShowGuess', foreign_key: 'photo_id'

  def ymd_elapsed
    ymd_elapsed_between dateadded, Time.now
  end

  def star_for_comments
    if other_user_comments >= 30
      :gold
    elsif other_user_comments >= 20
      :silver
    end
  end

  def star_for_views
    if views >= 3000
      :gold
    elsif views >= 1000
      :silver
    elsif views >= 300
      :bronze
    end
  end

  def star_for_faves
    if faves >= 100
      :gold
    elsif faves >= 30
      :silver
    elsif faves >= 10
      :bronze
    end
  end

  def has_obsolete_tags?
    if game_status.in?(%w(found revealed))
      raws = tags.map { |tag| tag.raw.downcase }
      raws.include?('unfoundinsf') &&
        ! (raws.include?('foundinsf') || game_status == 'revealed' && raws.include?('revealedinsf'))
    end
  end

end
