module PhotoScoreReportsSupport
  extend ActiveSupport::Concern
  include ScoreReportsSupport

  module ClassMethods
    def count_between(from, to)
      where('? < dateadded and dateadded <= ?', from.getutc, to.getutc).count
    end

    def unfound_or_unconfirmed_count_before(date)
      utc_date = date.getutc
      where("dateadded <= ?", utc_date)
        .where("not exists (select 1 from guesses where photo_id = photos.id and added_at <= ?)", utc_date)
        .where("not exists (select 1 from revelations where photo_id = photos.id and added_at <= ?)", utc_date)
        .count
    end

    def add_posts(people, to_date, attr_name)
      posts_per_person = where('dateadded <= ?', to_date.getutc).group(:person_id).count
      people.each do |person|
        person.send "#{attr_name}=", (posts_per_person[person.id] || 0)
      end
    end

  end

  def seconds_old
    (Time.now - dateadded).to_i
  end

end
