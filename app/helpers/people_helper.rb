module PeopleHelper

  def list_path(sorted_by)
    list_people_path :sorted_by => sorted_by,
      :order =>
        sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+'
  end

  def position(high_scorers, person)
    position = 0
    previous_score = nil
    high_scorers.each do |high_scorer|
      if high_scorer[:score] != previous_score
        position += 1
      end
      break if high_scorer == person
      previous_score = high_scorer[:score]
    end

    case position
    when 1 then ''
    when 2 then 'second-'
    when 3 then 'third-'
    end

  end

  def oldest_star_image(guess)
    case guess.years_old
    when 1
      '/images/star-bronze.gif'
    when 2
      '/images/star-silver.gif'
    else
      '/images/star-gold.gif'
    end
  end

  def fastest_star_image(guess)
    seconds_old = guess.seconds_old
    if seconds_old <= 10
      '/images/star-gold.gif'
    elsif seconds_old <= 60
      '/images/star-silver.gif'
    end
  end

end
