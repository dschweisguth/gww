require 'spec_helper'

describe ScoreReportsController do
  integrate_views

  describe '#index' do
    it "renders the page" do
      stub(ScoreReport).all { [ ScoreReport.make :created_at => Time.local(2011) ] }
      get :index
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'td', :text => 'Jan  1, 2011, 12:00 AM'
    end
  end

end
