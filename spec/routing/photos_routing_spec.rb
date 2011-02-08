require 'spec_helper'

describe PhotosController do
  describe 'routing' do
    it 'routes to list' do
      { :get => '/photos/list/sorted-by/foo/order/bar/page/666' }.should route_to \
        :controller => 'photos', :action => 'list', :sorted_by => 'foo', :order => 'bar', :page => '666' 
    end

    it 'routes to show' do
      { :get => '/photos/show/666' }.should route_to :controller => 'photos', :action => 'show', :id => '666'
    end

    it 'routes to a plain action' do
      { :get => '/photos/unfound' }.should route_to :controller => 'photos', :action => 'unfound'
    end

  end
end
