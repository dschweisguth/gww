module PrecalculatorJob
  class Job
    def self.run
      StatisticsPerson.update_statistics
      StatisticsPhoto.update_statistics
      StatisticsPhoto.infer_geocodes
      ::PageCache.clear
      "Updated statistics and maps."
    end
  end
end
