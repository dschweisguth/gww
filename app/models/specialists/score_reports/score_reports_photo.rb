class ScoreReportsPhoto < Photo
  include ScoreSupport, PhotoScoreSupport

  belongs_to :person, inverse_of: :photos, class_name: 'ScoreReportsPerson', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :photo, dependent: :destroy, class_name: 'ScoreReportsGuess', foreign_key: 'photo_id'

  def self.count_between(from, to)
    where('? < dateadded and dateadded <= ?', from.getutc, to.getutc).count
  end

  def self.unfound_or_unconfirmed_count_before(date)
    utc_date = date.getutc
    where("dateadded <= ?", utc_date).
      where("not exists (select 1 from guesses where photo_id = photos.id and added_at <= ?)", utc_date).
      where("not exists (select 1 from revelations where photo_id = photos.id and added_at <= ?)", utc_date).
      count
  end

  def self.add_posts(people, to_date, attr_name)
    posts_per_person = where('dateadded <= ?', to_date.getutc).group(:person_id).count
    people.each do |person|
      person.send "#{attr_name}=", (posts_per_person[person.id] || 0)
    end
  end

end
