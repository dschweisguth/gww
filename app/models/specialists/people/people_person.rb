class PeoplePerson < Person
  include PersonPeopleSupport

  has_many :photos, inverse_of: :person, class_name: 'PeoplePhoto', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :person, class_name: 'PeopleGuess', foreign_key: 'person_id'

  attr_accessor :poster

  def self.autocompletions(term)
    select(:username, :realname).
      where("username like ? or realname like ?", "#{term}%", "#{term}%").
      order("lower(username)").
      map { |person| { label: person.username_and_realname, value: person.username } }
  end

  def self.find_by_multiple_fields(username)
    find_by_username(username) || find_by_flickrid(username) || (username =~ /\d+/ && find_by_id(username))
  end

  def self.nemeses
    nemeses = find_by_sql %Q[
      select guessers.*, f.person_id poster_id,
        count(*) / posters_posts.post_count / guessers_guesses.guess_count * (select count(*) from photos) bias
      from guesses g, photos f, people guessers,
        (select person_id, count(*) post_count from photos
          group by person_id having count(*) >= #{Person::MIN_GUESSES_FOR_FAVORITE}) posters_posts,
        (select person_id, count(*) guess_count from guesses
          group by person_id) guessers_guesses
      where g.photo_id = f.id and
        g.person_id = guessers.id and
        f.person_id = posters_posts.person_id and
        g.person_id = guessers_guesses.person_id
      group by guessers.id, poster_id having count(*) >= 10 order by bias desc
    ]
    poster_ids = nemeses.map(&:poster_id).uniq
    posters_by_id = where(id: poster_ids).index_by &:id
    nemeses.each { |nemesis| nemesis.poster = posters_by_id[nemesis.poster_id] }
  end

  def self.top_guessers(report_time)
    days, weeks, months, years = top_guesser_periods report_time.getlocal

    [days, weeks, months, years].each do |periods|
      periods.each do |period|
        period.scores = top_guesser_scores period.start, period.finish
      end
    end

    return days, weeks, months, years
  end

  private_class_method def self.top_guesser_periods(report_time)
    report_day = report_time.beginning_of_day

    days = (0..6).map { |i| Period.starting_at(report_day - i.days, 1.day) }

    weeks = [Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day)] +
      (1..5).map { |i| Period.starting_at(report_day.beginning_of_week - i.weeks - 1.day, 1.week) }

    months = [Period.new(report_day.beginning_of_month, report_day + 1.day)] +
      (1..12).map { |i| Period.starting_at(report_day.beginning_of_month - i.month, 1.month) }

    years_of_guessing = report_day.getutc.year - Guess.first.commented_at.year
    years = [Period.new(report_day.beginning_of_year, report_day + 1.day)] +
      (1..years_of_guessing).map { |i| Period.starting_at(report_day.beginning_of_year - i.years, 1.year) }

    return days, weeks, months, years
  end

  private_class_method def self.top_guesser_scores(begin_date, end_date)
    PeoplePerson.
      select("people.*, count(*) score").
      joins(:guesses).
      where("? <= guesses.commented_at", begin_date.getutc).
      where("guesses.commented_at < ?", end_date.getutc).
      group("people.id").
      each_with_object({}) do |guesser, scores|
        scores[guesser.score] ||= []
        scores[guesser.score] << guesser
      end.
      tap do |scores|
        scores.values.each do |guessers_with_score|
          guessers_with_score.sort_by! { |guesser| guesser.username.downcase }
        end
      end
  end

  def guesses_with_associations_ordered_by_comments
    guesses.includes(photo: :person).order('commented_at desc')
  end

  def paginated_commented_photos(page, per_page = 25)
    PeoplePhoto.
      where("exists (select 1 from comments c where photos.id = c.photo_id and c.flickrid = ?)", flickrid).
      includes(:person, guesses: :person).
      order('lastupdate desc').
      paginate(page: page, per_page: per_page)
  end

end
