class IndexController < ApplicationController
  def index
    @last_update_time = last_update_time
  end
end
