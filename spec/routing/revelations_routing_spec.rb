require 'spec_helper'

describe RevelationsController do
  without_transactions

  it 'routes to a plain action' do
    should route(:get, '/revelations/longest').to :controller => 'revelations', :action => 'longest'
  end

end
