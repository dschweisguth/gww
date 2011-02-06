require 'spec_helper'

describe RevelationsController do
  integrate_views

  describe '#longest' do
    it 'renders the page' do
      stub(Revelation).longest { [ Revelation.make ] }
      get :longest

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a', :text => 'revelation_poster_username'

    end
  end

end
