describe Bounds, type: :lib do
  describe '#as_json' do
    it "jsonifies as you'd expect" do
      expect(Bounds.new(1, 2, 3, 4).as_json).to eq(min_lat: 1, max_lat: 2, min_long: 3, max_long: 4)
    end
  end
end
