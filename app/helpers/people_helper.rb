module PeopleHelper

  def list_path(sorted_by)
    list_people_path sorted_by,
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
    when 4 then 'fourth-'
    when 5 then 'fifth-'
    end

  end

  def image_for_star(star)
    case star
    when :bronze
      '/images/star-bronze.gif'
    when :silver
      '/images/star-silver.gif'
    when :gold
      '/images/star-gold.gif'
    end
  end

  def alt_for_star_for_age(star)
    case star
    when :bronze
      'Unfound for 1 year or more'
    when :silver
      'Unfound for 2 years or more'
    when :gold
      'Unfound for 3 years or more'
    end
  end

  def alt_for_star_for_speed(star)
    case star
    when :silver
      'Guessed in less than a minute'
    when :gold
      'Guessed in less than 10 seconds'
    end
  end

end
