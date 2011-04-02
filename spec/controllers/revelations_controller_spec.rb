require 'spec_helper'

describe RevelationsController do
  render_views
  without_transactions

  describe '#longest' do
    it 'renders the page' do
      stub(Revelation).longest { [ Revelation.make ] }
      get :longest

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'a', :content => 'revealed_photo_poster_username'

    end
  end

end
