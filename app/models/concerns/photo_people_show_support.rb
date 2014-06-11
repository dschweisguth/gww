module PhotoPeopleShowSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def oldest_unfound(poster)
      oldest_unfound =
        includes(:person).where("person_id = ? and game_status in ('unfound', 'unconfirmed')", poster).order(:dateadded).first
      if oldest_unfound
        oldest_unfound.place = count_by_sql([
          %q{
            select count(*)
            from
              (
                select min(dateadded) min_dateadded
                from photos where game_status in ('unfound', 'unconfirmed')
                group by person_id
              ) oldest_unfounds
            where min_dateadded < ?
          },
          oldest_unfound.dateadded
        ]) + 1
      end
      oldest_unfound
    end
  
    def most_commented(poster)
      most_commented = includes(:person).where(person_id: poster).order('other_user_comments desc').first
      if most_commented
        most_commented.place = count_by_sql([
          %q[
            select count(*)
            from (
              select max(other_user_comments) max_other_user_comments
              from photos
              group by person_id
            ) max_comments
            where max_other_user_comments > ?
          ],
          most_commented.other_user_comments
        ]) + 1
        most_commented
      else
        nil
      end
    end
  
    def most_viewed(poster)
      most_viewed = includes(:person).where(person_id: poster).order('views desc').first
      if most_viewed
        most_viewed.place = count_by_sql([
          %q[
            select count(*)
            from (
              select max(views) max_views
              from photos f
              group by person_id
            ) most_viewed
            where max_views > ?
          ],
          most_viewed.views
        ]) + 1
      end
      most_viewed
    end
  
    def most_faved(poster)
      most_faved = includes(:person).where(person_id: poster).order('faves desc').first
      if most_faved
        most_faved.place = count_by_sql([
          %q[
            select count(*)
            from (
              select max(faves) max_faves
              from photos f
              group by person_id
            ) most_faved
            where max_faves > ?
          ],
          most_faved.faves
        ]) + 1
      end
      most_faved
    end
  
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
