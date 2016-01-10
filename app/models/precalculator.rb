class Precalculator
  def self.calculate_statistics_and_maps
    Person.update_statistics
    Photo.update_statistics
    Photo.infer_geocodes
    PageCache.clear
    "Updated statistics and maps."
  end
end
