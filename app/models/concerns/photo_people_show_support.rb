module PhotoPeopleShowSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def find_with_guesses(person)
      where(person_id: person).includes(guesses: :person).includes(:tags)
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
