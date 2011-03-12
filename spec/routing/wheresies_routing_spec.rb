require 'spec_helper'

describe WheresiesController do
  without_transactions

  it 'routes to show' do
    { :get => '/wheresies/2010' }.should route_to :controller => 'wheresies', :action => 'show', :year => '2010'
  end

end
