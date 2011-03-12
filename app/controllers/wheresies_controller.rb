class WheresiesController < ApplicationController

  caches_page :show
  def show
    year = params[:year].to_i
    @most_points_in_2010 = Person.most_points_in
    @most_posts_in_2010 = Person.most_posts_in
    @rookies_with_most_points_in_2010 = Person.rookies_with_most_points_in
    @rookies_with_most_posts_in_2010 = Person.rookies_with_most_posts_in
    @most_viewed_in_2010 = Photo.most_viewed_in year
    @most_commented_in_2010 = Photo.most_commented_in year
    @shortest_in_2010 = Guess.shortest_in
    @longest_in_2010 = Guess.longest_in
  end

end
