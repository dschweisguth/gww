require 'spec_helper'

describe BookmarkletController do
  without_transactions

  it 'routes to a plain action' do
    { :get => '/bookmarklet/view' }.should route_to :controller => 'bookmarklet', :action => 'view'
  end

end
