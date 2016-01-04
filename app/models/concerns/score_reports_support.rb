module ScoreReportsSupport
  def years_old
    (seconds_old / (365 * 24 * 60 * 60)).truncate
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

end
