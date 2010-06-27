class GuessesController < ApplicationController

  caches_page :longest_and_shortest
  def longest_and_shortest
    @longest_guesses = Guess.longest
    add_time_elapsed @longest_guesses
    @shortest_guesses = Guess.shortest
    add_time_elapsed @shortest_guesses
  end

  def add_time_elapsed(guesses)
    guesses.each do |guess|
      guess[:time_elapsed] =
        time_elapsed guess.photo.dateadded, guess.guessed_at
    end
  end
  private :add_time_elapsed

  def time_elapsed(begin_date, end_date)
    years = end_date.year - begin_date.year
    months = end_date.month - begin_date.month
    days = end_date.day - begin_date.day
    hours = end_date.hour - begin_date.hour
    minutes = end_date.min - begin_date.min
    seconds = end_date.sec - begin_date.sec
    if seconds < 0
      seconds += 60
      minutes -= 1
    end
    if minutes < 0
      minutes += 60
      hours -= 1
    end
    if hours < 0
      hours += 24
      days -= 1
    end
    if days < 0
      days += 30
      months -= 1
    end
    if months < 0
      months += 12
      years -= 1
    end
    time_elapsed = []
    time_elapsed.push "#{years}&nbsp;years" if years > 0
    time_elapsed.push "#{months}&nbsp;months" if months > 0
    time_elapsed.push "#{days}&nbsp;days" if days > 0
    time_elapsed.push "#{hours}&nbsp;hours" if hours > 0
    time_elapsed.push "#{minutes}&nbsp;minutes" if minutes > 0
    time_elapsed.push "#{seconds}&nbsp;seconds" if seconds > 0
    time_elapsed.join ", "
  end
  private :time_elapsed

end
