describe Fixnum, type: :lib do
  describe '#ordinal' do
    expected = {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      11 => '11th',
      12 => '12th',
      13 => '13th',
      21 => '21st',
      22 => '22nd',
      23 => '23rd'
    }
    expected.keys.sort.each do |cardinal|
      it "converts the number #{cardinal} to its ordinal, #{expected[cardinal]}" do
        expect(cardinal.ordinal).to eq(expected[cardinal])
      end
    end
  end
end
