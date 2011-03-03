require 'spec_helper'

describe Admin::ScoreReportsController do
  integrate_views

  describe '#create' do
    it "creates and redirects" do
      mock(ScoreReport).create!
      post :create
      response.should redirect_to :controller => 'admin/guesses', :action => 'report'
    end
  end

end
