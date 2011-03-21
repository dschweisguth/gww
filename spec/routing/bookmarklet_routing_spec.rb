require 'spec_helper'

describe BookmarkletController do
  without_transactions

  describe 'show' do
    it { should have_named_route :bookmarklet, '/bookmarklet/show' }
    it { should route(:get, '/bookmarklet/show').to :controller => 'bookmarklet', :action => 'show' }
  end

end
