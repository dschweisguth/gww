class GuessesController < ApplicationController
  def treasures
    @longest_guesses = add_date_distances(Guess.longest)
    @shortest_guesses = add_date_distances(Guess.shortest)
  end

  def add_date_distances(guesses)
    annotated_guesses = []
    guesses.each do |guess|
      annotated_guesses.push({ :guess => guess, :elapsed_pretty =>
        get_date_distance(guess.photo.dateadded, guess.guessed_at)})
    end
    annotated_guesses
  end

  def get_date_distance(begin_date, end_date)
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
    desc = []
    if (years > 0) then desc.push("#{years} years") end
    if (months > 0) then desc.push("#{months} months") end
    if (days > 0) then desc.push("#{days} days") end
    if (hours > 0) then desc.push("#{hours} hours") end
    if (minutes > 0) then desc.push("#{minutes} minutes") end
    if (seconds > 0) then desc.push("#{seconds} seconds") end
    desc.join(", ")
  end

end
