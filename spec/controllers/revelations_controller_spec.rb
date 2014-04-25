require 'spec_helper'

describe RevelationsController do
  render_views

  describe '#longest' do
    it 'renders the page' do
      stub(Revelation).longest { [ Revelation.make ] }
      get :longest

      response.should be_success
      response.body.should have_link 'revealed_photo_poster_username'

    end
  end

end
