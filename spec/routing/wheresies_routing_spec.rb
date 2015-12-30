describe WheresiesController do

  describe '#show' do
    it { is_expected.to have_named_route :wheresies, 2010, '/wheresies/2010' }
    it { is_expected.to route(:get, '/wheresies/2010').to action: 'show', year: '2010' }
  end

end
