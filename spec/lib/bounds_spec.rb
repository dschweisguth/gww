require 'spec_helper'

describe Bounds do
  describe '#as_json' do
    it "jsonifies as you'd expect" do
      Bounds.new(1, 2, 3, 4).as_json.should == {
        :min_lat => 1,
        :max_lat => 2,
        :min_long => 3,
        :max_long => 4
      }
    end
  end
end
