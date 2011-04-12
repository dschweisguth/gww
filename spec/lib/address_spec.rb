require 'spec_helper'

describe Address do
  describe '.new' do

    it "makes a plain address" do
      address = Address.new 'text', 1, 'street_name', nil
      address.text.should == 'text'
      address.number.should == 1
      address.street.should == Street.new('street_name')
      address.at.should == nil
      address.between1.should == nil
      address.between2.should == nil
    end

    it "makes an address at an intersection" do
      address = Address.new 'text', 1, 'street_name', nil, 'at_name', nil
      address.text.should == 'text'
      address.number.should == 1
      address.street.should == Street.new('street_name')
      address.at.should == Street.new('at_name')
      address.between1.should == nil
      address.between2.should == nil
    end

    it "makes an address between streets" do
      address = Address.new 'text', 1, 'street_name', nil, 'between1_name', nil, 'between2_name', nil
      address.text.should == 'text'
      address.number.should == 1
      address.street.should == Street.new('street_name')
      address.at.should == nil
      address.between1.should == Street.new('between1_name')
      address.between2.should == Street.new('between2_name')
    end

    it "blows up if the first near street is nil and the second is non-nil" do
      lambda { Address.new('text', 1, 'street_name', nil, nil, nil, 'near_name', nil) }.should raise_error ArgumentError
    end

  end
end
