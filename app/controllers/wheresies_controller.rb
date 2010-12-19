class WheresiesController < ApplicationController

  caches_page :index
  def index
    @most_points_in_2010 = Person.most_points_in_2010
    @most_posts_in_2010 = Person.most_posts_in_2010
    @rookies_with_most_points_in_2010 = Person.rookies_with_most_points_in_2010
    @rookies_with_most_posts_in_2010 = Person.rookies_with_most_posts_in_2010
    @most_viewed_in_2010 = Photo.most_viewed_in_2010
    @most_commented_in_2010 = Photo.most_commented_in_2010
    @shortest_in_2010 = Guess.shortest_in_2010
  end

end
