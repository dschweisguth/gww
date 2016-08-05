module GuessScoreSupport
  def star_for_speed
    age = seconds_old
    if age <= 10
      :gold
    elsif age <= 60
      :silver
    end
  end

  def seconds_old
    (commented_at - photo.dateadded).to_i
  end

end
