module PhotoPeopleShowSupport
  extend ActiveSupport::Concern

  def has_obsolete_tags?
    if %w(found revealed).include?(game_status)
      raws = tags.map { |tag| tag.raw.downcase }
      raws.include?('unfoundinsf') &&
        ! (raws.include?('foundinsf') || game_status == 'revealed' && raws.include?('revealedinsf'))
    end
  end

end
