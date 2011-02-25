require 'spec_helper'

describe BookmarkletController do
  describe 'routing' do
    it 'routes to a plain action' do
      { :get => '/bookmarklet/view' }.should route_to :controller => 'bookmarklet', :action => 'view'
    end
  end
end
