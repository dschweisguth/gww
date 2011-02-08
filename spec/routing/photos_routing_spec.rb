require 'spec_helper'

describe PhotosController do
  describe 'routing' do
    describe 'list' do
      it 'is routed to' do
        { :get => '/photos/list/sorted-by/foo/order/bar/page/666' }.should route_to \
          :controller => 'photos', :action => 'list', :sorted_by => 'foo', :order => 'bar', :page => '666'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        list_photos_path('foo', 'bar', '1').should == '/photos/list/sorted-by/foo/order/bar/page/1'
      end

    end

    describe 'show' do
      it 'is routed to' do
        { :get => '/photos/show/666' }.should route_to :controller => 'photos', :action => 'show', :id => '666'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        show_photo_path(666).should == '/photos/show/666'
      end

    end

    it 'routes to a plain action' do
      { :get => '/photos/unfound' }.should route_to :controller => 'photos', :action => 'unfound'
    end

  end
end
