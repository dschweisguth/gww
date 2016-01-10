describe WheresiesController do
  describe '#show' do
    it { has_named_route? :wheresies, 2010, '/wheresies/2010' }
    it { does route(:get, '/wheresies/2010').to action: 'show', year: '2010' }
  end
end
