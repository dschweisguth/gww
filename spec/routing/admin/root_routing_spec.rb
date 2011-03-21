require 'spec_helper'

describe Admin::RootController do
  without_transactions

  describe 'index' do
    it { should have_named_route :admin_root, '/admin' }
    it { should route(:get, '/admin').to :controller => 'admin/root', :action => 'index' }
  end

  describe 'bookmarklet' do
    it { should route(:get, '/admin/bookmarklet').to :controller => 'admin/root', :action => 'bookmarklet' }
  end

end
