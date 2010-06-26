module PeopleHelper

  def list_url(sorted_by)
    list_people_url :sorted_by => sorted_by,
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

end
