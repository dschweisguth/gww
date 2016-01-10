module PhotoWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def most_viewed_in(year)
      most_loved_in year, :views
    end

    def most_faved_in(year)
      most_loved_in year, :faves
    end

    def most_loved_in(year, column)
      where('? <= dateadded', Time.local(year).getutc).where('dateadded < ?', Time.local(year + 1).getutc).
        order("#{column} desc").limit(10).includes(:person)
    end

    def most_commented_in(year)
      select("photos.*, count(*) comments").
        joins(:person).
        joins("join comments c on photos.id = c.photo_id and c.flickrid != people.flickrid").
        where("? <= photos.dateadded", Time.local(year).getutc).
        where("photos.dateadded < ?", Time.local(year + 1).getutc).
        group(:id).
        order("comments desc").
        limit 10
    end

  end

end
