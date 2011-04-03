require 'spec_helper'

describe RootController do
  without_transactions

  describe 'auto_complete_for_person_username' do
    it { should have_named_route :root_autocomplete_person_username, '/autocomplete_person_username' }
    it { should route(:get, '/autocomplete_person_username').to :controller => 'root', :action => 'autocomplete_person_username' }
  end

  describe 'root' do
    it { should have_named_route :root, '/' }
    it { should route(:get, '/').to :controller => 'root', :action => 'index' }
  end

  %w{ about bookmarklet }.each do |action|
    describe action do
      it { should have_named_route "root_#{action}", "/#{action}" }
      it { should route(:get, "/#{action}").to :controller => 'root', :action => action }
    end
  end

end
