module PrecalculatorJob
  class Job
    def self.run
      Person.update_statistics
      Photo.update_statistics
      Photo.infer_geocodes
      PageCache.clear
      "Updated statistics and maps."
    end
  end
end
