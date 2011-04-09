require 'spec_helper'

describe Location do

  describe 'make_valid' do

    it "rejects nil street1" do
      lambda { Location.make_valid nil, 'non-nil' }.should raise_error ArgumentError
    end

    # TODO Dave finish this job

  end

end
