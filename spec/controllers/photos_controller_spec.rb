require 'spec_helper'

describe PhotosController do
  integrate_views

  describe '#list' do
    it 'renders the page' do
      SORTED_BY_PARAM = 'username'
      ORDER_PARAM = '+'
      PAGE_PARAM = '1'

      # Mock methods from will_paginate's version of Array
      paginated_photos = [ Photo.new_for_test ]
      stub(paginated_photos).offset { 0 }
      stub(paginated_photos).total_pages { 1 }
      stub(Photo).all_sorted_and_paginated.with(SORTED_BY_PARAM, ORDER_PARAM, PAGE_PARAM, 30) { paginated_photos }
      get :list, :sorted_by => 'username', :order => ORDER_PARAM, :page => PAGE_PARAM

      #noinspection RubyResolve
      response.should be_success
      response.should have_tag 'a[href=/photos/list/sorted-by/username/order/-/page/1]', :text => 'posted by'
      response.should have_tag 'a[href=/people/show]', :text => 'poster_username'

    end
  end

end
