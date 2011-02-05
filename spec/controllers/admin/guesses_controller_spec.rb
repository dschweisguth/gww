require 'spec_helper'

describe Admin::GuessesController do
  integrate_views

  describe '#report' do
    it 'renders the page' do
      most_recent_update = FlickrUpdate.new_for_test :created_at => Time.local(2011)
      penultimate_update = FlickrUpdate.new_for_test :created_at => Time.local(2011, 1, 4)
      stub(FlickrUpdate).all { [ most_recent_update, penultimate_update ] }
      get :report

      #noinspection RubyResolve
      response.should be_success

    end
  end

end
