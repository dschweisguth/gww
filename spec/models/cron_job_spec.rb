require 'spec_helper'

describe CronJob do
  describe '#calculate_statistics_and_maps' do
    it "does some work" do
      mock(Person).update_statistics
      mock(Photo).update_statistics
      mock(Photo).infer_geocodes
      mock_clear_page_cache
      CronJob.calculate_statistics_and_maps.should == "Updated statistics and maps."
    end
  end
end
