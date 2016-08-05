module PersonScoreSupport
  def high_scorers(now, for_the_past_n_days)
    top_achievers :guesses, '? < guesses.commented_at and guesses.added_at <= ?', :score, now, for_the_past_n_days
  end

  def top_posters(now, for_the_past_n_days)
    top_achievers :photos, '? < photos.dateadded and photos.dateadded <= ?', :post_count, now, for_the_past_n_days
  end

  private def top_achievers(achievement, date_range, attribute, now, for_the_past_n_days)
    utc_now = now.getutc
    people =
      select("people.*, count(*) achievement_count").
        joins(achievement).
        where(date_range, utc_now - for_the_past_n_days.days, utc_now).
        group("people.id").
        having("achievement_count > 1").
        order("achievement_count desc, people.username")
    current_value = nil
    people.each_with_object([]) do |person, top_people|
      person.send "#{attribute}=", person[:achievement_count]
      if top_people.length >= 3 && person.send(attribute) < current_value
        break top_people
      end
      top_people << person
      current_value = person.send attribute
    end
  end

end
