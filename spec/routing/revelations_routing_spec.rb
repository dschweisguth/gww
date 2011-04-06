require 'spec_helper'

describe RevelationsController do

  describe 'longest' do
    it { should have_named_route :longest_revelations, '/revelations/longest' }
    it { should route(:get, '/revelations/longest').to :action => 'longest' }
  end

end
