require 'spec_helper'

describe Admin::RootController do
  without_transactions

  describe 'index' do
    it 'has a named route' do
      #noinspection RubyResolve
      admin_root_path.should == '/admin'
    end

    it { should route(:get, '/admin').to :controller => 'admin/root', :action => 'index' }

  end

  it { should route(:get, '/admin/bookmarklet').to :controller => 'admin/root', :action => 'bookmarklet' }

end
