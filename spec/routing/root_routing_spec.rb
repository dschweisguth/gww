require 'spec_helper'

describe RootController do

  describe 'root' do
    it { should have_named_route :root, '/' }
    it { should route(:get, '/').to :action => 'index' }
  end

  %w{ about bookmarklet }.each do |action|
    describe action do
      it { should have_named_route "root_#{action}", "/#{action}" }
      it { should route(:get, "/#{action}").to :action => action }
    end
  end

  describe 'about-auto-mapping' do
    it { should have_named_route "root_about_auto_mapping", "/about-auto-mapping" }
    it { should route(:get, "/about-auto-mapping").to :action => 'about_auto_mapping' }
  end

end
