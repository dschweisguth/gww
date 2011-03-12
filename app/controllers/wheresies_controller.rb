class WheresiesController < ApplicationController

  caches_page :show
  def show
    year = params[:year].to_i
    @most_points_in_year = Person.most_points_in year
    @most_posts_in_year = Person.most_posts_in year
    @rookies_with_most_points_in_year = Person.rookies_with_most_points_in year
    @rookies_with_most_posts_in_year = Person.rookies_with_most_posts_in year
    @most_viewed_in_year = Photo.most_viewed_in year
    @most_commented_in_year = Photo.most_commented_in year
    @shortest_in_year = Guess.shortest_in year
    @longest_in_year = Guess.longest_in year
  end

end
