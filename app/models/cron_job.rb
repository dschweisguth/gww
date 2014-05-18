# TODO Dave give this a better name
class CronJob

  def self.calculate_statistics_and_maps
    Person.update_statistics
    Photo.update_statistics
    Photo.infer_geocodes
    PageCache.clear
    return "Updated statistics and maps."
  end

end
