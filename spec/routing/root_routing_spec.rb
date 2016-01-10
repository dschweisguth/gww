describe RootController do
  describe 'root' do
    it { has_named_route? :root, '/' }
    it { does route(:get, '/').to action: 'index' }
  end

  %w(about bookmarklet).each do |action|
    describe action do
      it { has_named_route? "root_#{action}", "/#{action}" }
      it { does route(:get, "/#{action}").to action: action }
    end
  end

  describe 'about-auto-mapping' do
    it { has_named_route? "root_about_auto_mapping", "/about-auto-mapping" }
    it { does route(:get, "/about-auto-mapping").to action: 'about_auto_mapping' }
  end

end
