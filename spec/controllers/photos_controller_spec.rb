require 'spec_helper'

describe PhotosController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      # Mock methods from will_paginate's version of Array
      paginated_photos = [ Photo.new_for_test ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).all_sorted_and_paginated.with('username', '+', '1', 30) { paginated_photos }
      get :list, :sorted_by => 'username', :order => '+', :page => 1

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/photos/list/sorted-by/username/order/-/page/1]', :text => 'posted by'
      response.should have_tag 'a[href=/people/show]', :text => 'poster_username'

    end
  end

end
