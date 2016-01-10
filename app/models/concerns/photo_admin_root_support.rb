module PhotoAdminRootSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def unfound_or_unconfirmed_count
      where("game_status in ('unfound', 'unconfirmed')").count
    end

    def inaccessible_count
      where("seen_at < ?", FlickrUpdate.maximum(:created_at)).where("game_status in ('unfound', 'unconfirmed')").count
    end

    def multipoint_count
      connection.execute("select count(*) from (#{multipoint_without_associations.to_sql}) rows").first.first.to_i
    end

  end

end
