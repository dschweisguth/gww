class ApplicationController < ActionController::Base

  def last_update_time
     FlickrUpdate.maximum(:updated_at)
  end

  # TODO use as little as possible
  def adj_last_update_time
    last_update_time - 28800;
  end

end
