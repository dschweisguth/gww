require 'spec_helper'

describe WheresiesController do
  render_views

  describe '#show' do

    it 'bails out if the year is invalid' do
      stub(ScoreReport).order.stub!.first { build :score_report, created_at: Time.local(2010).getutc }
      stub(Time).now { Time.local(2010) }
      lambda { get :show, year: '2011' }.should raise_error ActiveRecord::RecordNotFound
    end

    it "doesn't says 'preliminary' if it's not for this year" do
      stub(ScoreReport).order.stub!.first { build :score_report, created_at: Time.local(2009).getutc }
      stub(Time).now { Time.local(2010) }
      get :show, year: '2009'
      response.should be_success
      response.body.should_not have_css 'h1', text: '2009 Wheresies (preliminary)'
    end

  end

end
