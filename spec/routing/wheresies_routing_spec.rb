require 'spec_helper'

describe WheresiesController do
  without_transactions

  describe '#show' do
    it { should route(:get, '/wheresies/2010').to :controller => 'wheresies', :action => 'show', :year => '2010' }
  end

end
