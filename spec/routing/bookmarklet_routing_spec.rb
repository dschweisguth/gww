require 'spec_helper'

describe BookmarkletController do
  without_transactions

  it 'routes to a plain action' do
    should route(:get, '/bookmarklet/view').to :controller => 'bookmarklet', :action => 'view'
  end

end
