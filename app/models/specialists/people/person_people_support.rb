module PersonPeopleSupport
  def mapped_photo_count
    photos.where('accuracy >= 12 or inferred_latitude is not null').count
  end

  def mapped_guess_count
    guesses.joins(:photo).where('photos.accuracy >= 12 || photos.inferred_latitude is not null').count
  end

  def username_and_realname
    realname.present? && realname != username ? "#{username} (#{realname})" : username
  end

end
