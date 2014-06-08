module GuessScoreReportsSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def all_between(from, to)
      where("? < added_at and added_at <= ?", from.getutc, to.getutc)
        .order(:commented_at).includes(:person, { photo: :person })
    end

  end

  def years_old
    (seconds_old / (365 * 24 * 60 * 60)).truncate
  end

  def seconds_old
    (self.commented_at - self.photo.dateadded).to_i
  end

  def star_for_age
    age = years_old
    if age >= 3
      :gold
    elsif age >= 2
      :silver
    elsif age >= 1
      :bronze
    else
      nil
    end
  end

  def star_for_speed
    age = seconds_old
    if age <= 10
      :gold
    elsif age <= 60
      :silver
    else
      nil
    end
  end

end
