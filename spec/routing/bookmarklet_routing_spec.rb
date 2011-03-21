require 'spec_helper'

describe BookmarkletController do
  without_transactions

  describe 'view' do
    it { should have_named_route :bookmarklet, '/bookmarklet/view' }
    it { should route(:get, '/bookmarklet/view').to :controller => 'bookmarklet', :action => 'view' }
  end

end
