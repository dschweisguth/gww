require 'spec_helper'

describe BookmarkletController do

  describe 'show' do
    it { should have_named_route :bookmarklet, '/bookmarklet/show' }
    it { should route(:get, '/bookmarklet/show').to action: 'show' }
  end

end
