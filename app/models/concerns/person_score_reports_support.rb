module PersonScoreReportsSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def all_before(date)
      utc_date = date.getutc
      where "exists (select 1 from photos where person_id = people.id and dateadded <= ?) or " \
        "exists (select 1 from guesses where person_id = people.id and added_at <= ?)", utc_date, utc_date
    end

    def high_scorers(now, for_the_past_n_days)
      top_achievers :guesses, '? < guesses.commented_at and guesses.added_at <= ?', :score, now, for_the_past_n_days
    end

    def top_posters(now, for_the_past_n_days)
      top_achievers :photos, '? < photos.dateadded and photos.dateadded <= ?', :post_count, now, for_the_past_n_days
    end

    def top_achievers(achievement, date_range, attribute, now, for_the_past_n_days)
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

    def by_score(people, to_date)
      scores = Guess.where('added_at <= ?', to_date.getutc).group(:person_id).count
      people.group_by { |person| scores[person.id] || 0 }
    end

    # people and people_by_score contain the same people instances. guessers has different people instances.
    # guessers: people who guessed in this reporting period and their guesses, in the form [[Person, [Guess, ...]], ...]
    def add_change_in_standings(people_by_score, people, previous_report_date, guessers)
      add_score_and_place people_by_score, :score, :place
      people_by_previous_score = by_score people, previous_report_date
      add_score_and_place people_by_previous_score, :previous_score, :previous_place
      Photo.add_posts people, previous_report_date, :previous_post_count
      scored_people = people.map { |person| [person, person] }.to_h
      guessers.each do |guesser_and_guesses|
        guesser = guesser_and_guesses[0]
        scored_guesser = scored_people[guesser]
        change_in_standings = change_in_standings scored_guesser, people, people_by_score
        achievements = achievements scored_guesser
        guesser.change_in_standing = [change_in_standings, achievements].select(&:present?).join '. '
      end
    end

    # public only for testing
    def add_score_and_place(people_by_score, score_attr_name, place_attr_name)
      place = 1
      people_by_score.sort { |a, b| b[0] <=> a[0] }.each do |score, people_with_score|
        people_with_score.each do |person|
          person.send "#{score_attr_name}=", score
          person.send "#{place_attr_name}=", place
        end
        place += people_with_score.length
      end
    end

    private def change_in_standings(guesser, people, people_by_score)
      if guesser.previous_score == 0
        score = guesser.score
        "scored his or her first point#{if score > 1 then " (and #{score - 1} more)" end}. " +
          (guesser.previous_post_count == 0 ? 'Congratulations, and welcome to GWSF!' : 'Congratulations!')
      else
        place = guesser.place
        previous_place = guesser.previous_place
        if place < previous_place
          advancements = advancements guesser, people, people_by_score
          (previous_place - place > 1 ? 'jumped' : 'climbed') +
            " from #{previous_place.ordinal} to #{place.ordinal} place" +
            if advancements.present? then ", #{advancements}" end.to_s
        end
      end
    end

    private def advancements(guesser, people, people_by_score)
      threats = []
      passed = people.find_all { |person| person.previous_place < guesser.previous_place && person.place > guesser.place }
      if passed.length == 1 || passed.any? && guesser.previous_place - guesser.place == 2
        threats << "passing #{opponent_or_opponents passed}"
      end
      ties = people_by_score[guesser.score] - [guesser]
      if ties.any?
        threats << "tying #{opponent_or_opponents ties}"
      end
      threats.join ' and '
    end

    private def opponent_or_opponents(opponents)
      opponents.length == 1 ? opponents[0].username : "#{opponents.length} other players"
    end

    # TODO make this work for boundaries above 5000
    MILESTONES = [100, 200, 300, 400, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]

    CLUBS = {
      21 => "https://www.flickr.com/photos/inkvision/2976263709/",
      65 => "https://www.flickr.com/photos/deadslow/232833608/",
      222 => "https://www.flickr.com/photos/potatopotato/90592664/",
      365 => "https://www.flickr.com/photos/glasser/5065771787/",
      500 => "https://www.flickr.com/photos/spine/2960364433/",
      540 => "https://www.flickr.com/photos/tomhilton/2780581249/",
      3300 => "https://www.flickr.com/photos/spine/3132055535/"
    }

    private def achievements(guesser)
      score = guesser.score
      previous_score = guesser.previous_score
      achievements = []
      milestone = MILESTONES.find { |milestone| previous_score < milestone && milestone <= score }
      append(achievements, milestone) { "Congratulations on #{score == milestone ? 'reaching' : 'passing'} #{milestone} points!" }
      club = CLUBS.keys.find { |club| previous_score < club && club <= score }
      append(achievements, club) { "Welcome to <a href=\"#{CLUBS[club]}\">the #{club} Club</a>!" }
      entered_top_ten = guesser.previous_place > 10 && guesser.place <= 10
      append(achievements, entered_top_ten) { 'Welcome to the top ten!' }
      achievements.join ' '
    end

    private def append(achievements, value)
      if value
        achievements << yield
      end
    end

  end

end
