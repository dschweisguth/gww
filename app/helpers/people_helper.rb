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

  def thumbnail_with_alt(photo)
    thumbnail photo, render('shared/alt', :photo => photo)
  end

  def place(trophy, reason)
    star, alt = star_and_alt(trophy, reason)
    render 'people/show/place', :trophy => trophy, :star => star, :alt => alt
  end

  ALT = {
    :age => {
      :bronze => 'Unfound for 1 year or more',
      :silver => 'Unfound for 2 years or more',
      :gold => 'Unfound for 3 years or more'
    },
    :speed => {
      :silver => 'Guessed in less than a minute',
      :gold => 'Guessed in less than 10 seconds'
    },
    :comments => {
      :silver => '20 or more comments',
      :gold => '30 or more comments'
    },
    :views => {
      :bronze => '300 or more views',
      :silver => '1000 or more views',
      :gold => '3000 or more views'
    }
  }

  def star_and_alt(trophy, reason)
    star = trophy.send "star_for_#{reason}"
    return star, ALT[reason][star]
  end

  def position(high_scorers, person, attr)
    position = 0
    score_for_this_position = 1.0/0
    high_scorers.each_with_index do |high_scorer, i|
      if high_scorer[attr] < score_for_this_position
        position = i + 1
        score_for_this_position = high_scorer[attr]
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

end
