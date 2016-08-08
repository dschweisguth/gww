module PersonScoreSupport
  def high_scorers(now, for_the_past_n_days)
    top_achievers :guesses, '? < guesses.commented_at and guesses.added_at <= ?', :high_score, now, for_the_past_n_days
  end

  def top_posters(now, for_the_past_n_days)
    top_achievers :photos, '? < photos.dateadded and photos.dateadded <= ?', :top_post_count, now, for_the_past_n_days
  end

  # attribute must not be the name of an attribute defined with attr_accessor
  private def top_achievers(achievement, date_range, attribute, now, for_the_past_n_days)
    utc_now = now.getutc
    select("people.*, count(*) #{attribute}").
      joins(achievement).
      where(date_range, utc_now - for_the_past_n_days.days, utc_now).
      group("people.id").
      having("#{attribute} > 1").
      order("#{attribute} desc, people.username").
      each_with_object([]) do |person, top_people|
        if top_people.length >= 3 && person.send(attribute) < top_people.last.try(:send, attribute)
          break top_people
        end
        top_people << person
      end
  end

end
