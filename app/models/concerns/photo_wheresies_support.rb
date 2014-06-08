module PhotoWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def most_viewed_in(year)
      where('? <= dateadded and dateadded < ?', Time.local(year).getutc, Time.local(year + 1).getutc)
        .order('views desc').limit(10).includes(:person)
    end
  
    def most_faved_in(year)
      where('? <= dateadded and dateadded < ?', Time.local(year).getutc, Time.local(year + 1).getutc)
        .order('faves desc').limit(10).includes(:person)
    end
  
    def most_commented_in(year)
      find_by_sql [
        %q{
          select f.*, count(*) comments from photos f, people p, comments c
          where ? <= f.dateadded and f.dateadded < ? and
            f.person_id = p.id and
            f.id = c.photo_id and
            c.flickrid != p.flickrid
          group by f.id order by comments desc limit 10
        },
        Time.local(year).getutc, Time.local(year + 1).getutc ]
    end

  end

end
