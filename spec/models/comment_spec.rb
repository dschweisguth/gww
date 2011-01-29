require 'spec_helper'

describe Comment do
  it "should belong to a photo" do
    should belong_to :photo
  end
end
