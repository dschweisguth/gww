module PeopleHelper

  def list_path(sorted_by)
    list_people_path sorted_by,
      sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+'
  end

  def to_4_places(x)
    sprintf("%.4f", x)
  end

  def infinity_or(x)
    x.infinite? ? '&#8734;' : to_4_places(x)
  end

  def position(high_scorers, person)
    position = 0
    score_for_this_position = 1.0/0
    high_scorers.each_with_index do |high_scorer, i|
      if high_scorer[:score] < score_for_this_position
        position = i + 1
        score_for_this_position = high_scorer[:score]
      end
      break if high_scorer == person
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
