require 'spec_helper'

describe PhotosController do
  describe 'routing' do
    it 'routes to list' do
      { :get => '/photos/list/sorted-by/foo/order/bar/page/666' }.should route_to \
        :controller => 'photos', :action => 'list', :sorted_by => 'foo', :order => 'bar', :page => '666' 
    end
  end
end
