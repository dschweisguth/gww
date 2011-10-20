class WheresiesController < ApplicationController

  caches_page :show
  def show
    @wheresies_years = ScoreReport.order(:created_at).first.created_at.getlocal.year .. Time.now.year
    @year = params[:year].to_i
    if ! @wheresies_years.include? @year
      raise ActiveRecord::RecordNotFound, "We don't know anything about the Wheresies for that year."
    end
    @most_points_in_year = Person.most_points_in @year
    @most_posts_in_year = Person.most_posts_in @year
    @rookies_with_most_points_in_year = Person.rookies_with_most_points_in @year
    @rookies_with_most_posts_in_year = Person.rookies_with_most_posts_in @year
    @most_viewed_in_year = Photo.most_viewed_in @year
    @most_faved_in_year = Photo.most_faved_in @year
    @most_commented_in_year = Photo.most_commented_in @year
    @shortest_in_year = Guess.shortest_in @year
    @longest_in_year = Guess.longest_in @year
  end

end
