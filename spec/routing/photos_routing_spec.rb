require 'spec_helper'

describe PhotosController do
  without_transactions

  describe 'index' do
    it { should have_named_route :photos, 'foo', 'bar', 666, '/photos/sorted-by/foo/order/bar/page/666' }
    it { should route(:get, '/photos/sorted-by/foo/order/bar/page/666').to(
      :controller => 'photos', :action => 'index', :sorted_by => 'foo', :order => 'bar', :page => '666') }
  end

  describe 'show' do
    it 'has a named route' do
      #noinspection RubyResolve
      show_photo_path(666).should == '/photos/show/666'
    end

    it { should route(:get, '/photos/show/666').to :controller => 'photos', :action => 'show', :id => '666' }

  end

  it 'routes to a plain action' do
    should route(:get, '/photos/unfound').to :controller => 'photos', :action => 'unfound'
  end

  it 'routes to a plain action with an ID' do
    should route(:get, '/photos/show/666').to :controller => 'photos', :action => 'show', :id => '666'
  end

end
