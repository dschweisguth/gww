class AdminRootPhoto < Photo
  def self.unfound_or_unconfirmed_count
    where("game_status in ('unfound', 'unconfirmed')").count
  end

  def self.inaccessible_count
    where("seen_at < ?", FlickrUpdate.maximum(:created_at)).where("game_status in ('unfound', 'unconfirmed')").count
  end

  def self.multipoint_count
    connection.execute("select count(*) from (#{multipoint_without_associations.to_sql}) multipoint_without_associations").first.first.to_i
  end

end
