module PersonScoreReportsSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def all_before(date)
      utc_date = date.getutc
      find_by_sql [
          %q[
            select p.* from people p
            where exists (select 1 from photos where person_id = p.id and dateadded <= ?) or
              exists (select 1 from guesses where person_id = p.id and added_at <= ?)
          ],
          utc_date, utc_date
      ]
    end
    
    def high_scorers(now, for_the_past_n_days)
      utc_now = now.getutc
      people = find_by_sql [ %q{
        select p.*, count(*) score from people p, guesses g
        where p.id = g.person_id and ? < g.commented_at and g.added_at <= ?
        group by p.id having score > 1 order by score desc
      }, utc_now - for_the_past_n_days.days, utc_now]
      high_scorers = []
      current_score = nil
      people.each do |person|
        person.score = person[:score]
        break if high_scorers.length >= 3 && person.score < current_score
        high_scorers << person
        current_score = person.score
      end
      high_scorers
    end
  
    def top_posters(now, for_the_past_n_days)
      utc_now = now.getutc
      people = find_by_sql [ %q{
        select p.*, count(*) post_count from people p, photos f
        where p.id = f.person_id and ? < f.dateadded and f.dateadded <= ?
        group by p.id having post_count > 1 order by post_count desc
      }, utc_now - for_the_past_n_days.days, utc_now]
      top_posters = []
      current_post_count = nil
      people.each do |person|
        person.post_count = person[:post_count]
        break if top_posters.length >= 3 && person.post_count < current_post_count
        top_posters << person
        current_post_count = person.post_count
      end
      top_posters
    end
  
    def by_score(people, to_date)
      scores = Guess.where('added_at <= ?', to_date.getutc).group(:person_id).count
      people_by_score = {}
      people.each do |person|
        score = scores[person.id] || 0
        people_with_score = people_by_score[score]
        if ! people_with_score
          people_with_score = []
          people_by_score[score] = people_with_score
        end
        people_with_score << person
      end
      people_by_score
    end
  
    CLUBS = {
      21 => "https://www.flickr.com/photos/inkvision/2976263709/",
      65 => "https://www.flickr.com/photos/deadslow/232833608/",
      222 => "https://www.flickr.com/photos/potatopotato/90592664/",
      365 => "https://www.flickr.com/photos/glasser/5065771787/",
      500 => "https://www.flickr.com/photos/spine/2960364433/",
      540 => "https://www.flickr.com/photos/tomhilton/2780581249/",
      3300 => "https://www.flickr.com/photos/spine/3132055535/"
    }
  
    # TODO make this work for boundaries above 5000
    MILESTONES = [ 100, 200, 300, 400, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 ]
  
    def add_change_in_standings(people_by_score, people, previous_report_date, guessers)
      add_score_and_place people_by_score, :score, :place
      people_by_previous_score = Person.by_score people, previous_report_date
      add_score_and_place people_by_previous_score, :previous_score, :previous_place
      Photo.add_posts people, previous_report_date, :previous_post_count
      scored_people = people.map { |person| [person, person] }.to_h
      guessers.each do |guesser_and_guesses|
        guesser = guesser_and_guesses[0]
        scored_guesser = scored_people[guesser]
        score = scored_guesser.score
        previous_score = scored_guesser.previous_score
        if previous_score == 0 && score > 0
          change = 'scored his or her first point'
          if score > 1
            change << " (and #{score - 1} more)"
          end
          change << (scored_guesser.previous_post_count == 0 \
            ? '. Congratulations, and welcome to GWSF!' \
            : '. Congratulations!')
        else
          place = scored_guesser.place
          previous_place = scored_guesser.previous_place
          if place < previous_place
            change = "#{previous_place - place > 1 ? 'jumped' : 'climbed'} from #{previous_place.ordinal} to #{place.ordinal} place"
            passed =
              people.find_all { |person| person.previous_place < scored_guesser.previous_place } &
                people.find_all { |person| person.place > scored_guesser.place }
            ties = people_by_score[score] - [ scored_guesser ]
            show_passed = passed.length == 1 || passed.length > 0 && previous_place - place == 2
            if show_passed || ties.length > 0
              change << ','
            end
            if show_passed
              change << " passing #{passed.length == 1 ? passed[0].username : "#{passed.length} other players" }"
            end
            if ties.length > 0
              if show_passed
                change << ' and'
              end
              change << ' tying '
              change << (ties.length == 1 ? ties[0].username : "#{ties.length} other players")
            end
          else
            change = ''
          end
          club = CLUBS.keys.find { |club| previous_score < club && club <= score }
          milestone = club ? nil : MILESTONES.find { |milestone| previous_score < milestone && milestone <= score }
          entered_top_ten = previous_place > 10 && place <= 10
          if (club || milestone || entered_top_ten) && ! change.empty?
            change << '.'
          end
          append(change, club) { "Welcome to <a href=\"#{CLUBS[club]}\">the #{club} Club</a>!" }
          append(change, milestone) { "Congratulations on #{score == milestone ? 'reaching' : 'passing'} #{milestone} points!" }
          append(change, entered_top_ten) { 'Welcome to the top ten!' }
        end
        guesser.change_in_standing = change
      end
    end
  
    # public only for testing
    def add_score_and_place(people_by_score, score_attr_name, place_attr_name)
      place = 1
      people_by_score.keys.sort { |a, b| b <=> a }.each do |score|
        people_with_score = people_by_score[score]
        people_with_score.each do |person|
          person.send "#{score_attr_name}=", score
          person.send "#{place_attr_name}=", place
        end
        place += people_with_score.length
      end
    end

    private def append(change, value)
      if value
        if ! change.empty?
          change << ' '
        end
        change << yield
      end
    end
  
  end

end