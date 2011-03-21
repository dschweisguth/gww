require 'spec_helper'

describe RootController do
  without_transactions

  describe 'root' do
    it { should have_named_route :root, '/' }
    it { should route(:get, '/').to :controller => 'root', :action => 'index' }
  end

  it 'routes to a plain action' do
    should route(:get, 'about').to :controller => 'root', :action => 'about'
  end

end
