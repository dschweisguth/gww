require 'spec_helper'

describe WheresiesController do
  describe 'routing' do
    it 'routes to index' do
      { :get => '/wheresies' }.should route_to :controller => 'wheresies', :action => 'index'
    end
  end
end
