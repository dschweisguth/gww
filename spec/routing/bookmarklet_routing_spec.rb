require 'spec_helper'

describe BookmarkletController do
  without_transactions

  it { should route(:get, '/bookmarklet/view').to :controller => 'bookmarklet', :action => 'view' }

end
