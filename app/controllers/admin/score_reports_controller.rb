class Admin::ScoreReportsController < ApplicationController

  def create
    ScoreReport.create!
    redirect_to :controller => 'admin/guesses', :action => 'report'
  end

end
