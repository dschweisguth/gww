require 'spec_helper'

describe RootController do
  without_transactions

  describe 'root' do
    it 'has a named route' do
      root_path.should == '/'
    end

    it { should route(:get, '/').to :controller => 'root', :action => 'index' }

  end

  it 'routes to a plain action' do
    should route(:get, 'about').to :controller => 'root', :action => 'about'
  end

end
