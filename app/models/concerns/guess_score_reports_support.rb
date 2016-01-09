module GuessScoreReportsSupport
  extend ActiveSupport::Concern
  include ScoreReportsSupport

  module ClassMethods
    def all_between(from, to)
      where("? < added_at", from.getutc).where("added_at <= ?", to.getutc)
        .order(:commented_at).includes(:person, photo: :person)
    end
  end

  def seconds_old
    (commented_at - photo.dateadded).to_i
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
