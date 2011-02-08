require 'spec_helper'

describe PeopleController do
  describe 'routing' do
    it 'routes to list' do
      { :get => '/people/list/sorted-by/foo/order/bar' }.should route_to \
        :controller => 'people', :action => 'list', :sorted_by => 'foo', :order => 'bar'
    end
  end
end
