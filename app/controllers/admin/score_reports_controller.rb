class Admin::ScoreReportsController < ApplicationController
  # TODO Dave test
  def create
    ScoreReport.create!
    redirect_to :controller => 'admin/guesses', :action => 'report'
  end
end
