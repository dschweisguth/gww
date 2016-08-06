class WheresiesPhoto < Photo
  belongs_to :person, inverse_of: :photos, class_name: 'WheresiesPerson', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :photo, dependent: :destroy, class_name: 'WheresiesGuess', foreign_key: 'photo_id'

  def self.most_viewed_in(year)
    most_loved_in year, :views
  end

  def self.most_faved_in(year)
    most_loved_in year, :faves
  end

  def self.most_loved_in(year, column)
    where('? <= dateadded', Time.local(year).getutc).where('dateadded < ?', Time.local(year + 1).getutc).
      order("#{column} desc").limit(10).includes(:person)
  end

  def self.most_commented_in(year)
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
