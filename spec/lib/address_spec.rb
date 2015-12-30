describe Address, type: :lib do
  describe '.new' do

    it "makes a plain address" do
      address = Address.new 'text', 1, 'street_name', nil
      expect(address.text).to eq('text')
      expect(address.number).to eq(1)
      expect(address.street).to eq(Street.new('street_name'))
      expect(address.at).to eq(nil)
      expect(address.between1).to eq(nil)
      expect(address.between2).to eq(nil)
    end

    it "makes an address at an intersection" do
      address = Address.new 'text', 1, 'street_name', nil, 'at_name', nil
      expect(address.text).to eq('text')
      expect(address.number).to eq(1)
      expect(address.street).to eq(Street.new('street_name'))
      expect(address.at).to eq(Street.new('at_name'))
      expect(address.between1).to eq(nil)
      expect(address.between2).to eq(nil)
    end

    it "makes an address between streets" do
      address = Address.new 'text', 1, 'street_name', nil, 'between1_name', nil, 'between2_name', nil
      expect(address.text).to eq('text')
      expect(address.number).to eq(1)
      expect(address.street).to eq(Street.new('street_name'))
      expect(address.at).to eq(nil)
      expect(address.between1).to eq(Street.new('between1_name'))
      expect(address.between2).to eq(Street.new('between2_name'))
    end

    it "blows up if the first near street is nil and the second is non-nil" do
      expect { Address.new('text', 1, 'street_name', nil, nil, nil, 'near_name', nil) }.to raise_error ArgumentError
    end

  end
end
