require 'spec_helper'

describe PeopleController do
  describe 'routing' do
    describe 'list' do
      it 'is routed to' do
        { :get => '/people/list/sorted-by/foo/order/bar' }.should route_to \
          :controller => 'people', :action => 'list', :sorted_by => 'foo', :order => 'bar'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        list_people_path('foo', 'bar').should == '/people/list/sorted-by/foo/order/bar'
      end

    end

    describe 'show' do
      it 'is routed to' do
        { :get => '/people/show/666' }.should route_to \
          :controller => 'people', :action => 'show', :id => '666'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        show_person_path(666).should == '/people/show/666'
      end

    end

  it 'routes to a plain action' do
    { :get => '/people/top_guessers' }.should route_to :controller => 'people', :action => 'top_guessers'
  end

  end
end
