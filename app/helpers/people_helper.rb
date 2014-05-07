module PeopleHelper

  def other_people_path(sorted_by)
    #noinspection RubyResolve
    people_path sorted_by,
      sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+'
  end

  def to_4_places(x)
    sprintf("%.4f", x)
  end

  def infinity_or(x)
    x == Float::MAX ? '&#8734;' : to_4_places(x)
  end

  def thumbnail_with_alt(photo)
    thumbnail photo, render('shared/alt', photo: photo)
  end

  def place(trophy, reason)
    star, alt = star_and_alt(trophy, reason)
    render 'people/show/place', trophy: trophy, star: star, alt: alt
  end

  ALT = {
    age: {
      bronze: 'Unfound for 1 year or more',
      silver: 'Unfound for 2 years or more',
      gold: 'Unfound for 3 years or more'
    },
    speed: {
      silver: 'Guessed in less than a minute',
      gold: 'Guessed in less than 10 seconds'
    },
    comments: {
      silver: '20 or more comments',
      gold: '30 or more comments'
    },
    views: {
      bronze: '300 or more views',
      silver: '1000 or more views',
      gold: '3000 or more views'
    },
    faves: {
      bronze: '10 or more faves',
      silver: '30 or more faves',
      gold: '100 or more faves'
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
      if high_scorer.send(attr) < score_for_this_position
        position = i + 1
        score_for_this_position = high_scorer.send attr
      end
      break if high_scorer == person
    end
    {
      1 => '',
      2 => 'second-',
      3 => 'third-',
      4 => 'fourth-',
      5 => 'fifth-'
    }[position]
  end

  def image_for_star(star)
    {
      bronze: '/images/star-bronze.gif',
      silver: '/images/star-silver.gif',
      gold: '/images/star-gold.gif'
    }[star]
  end

end
