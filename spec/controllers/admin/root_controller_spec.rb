require 'spec_helper'

describe Admin::RootController do
  integrate_views

  describe '#bookmarklet' do
    it 'renders the page' do
      get :bookmarklet
      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/bookmarklet]'
    end
  end

end
