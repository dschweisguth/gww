# Adapt Rails tests to Ruby 2.6
# From https://github.com/rails/rails/issues/34790
class ActionController::TestResponse < ActionDispatch::TestResponse
  def recycle!
    # hack to avoid MonitorMixin double-initialize error:
    @mon_mutex_owner_object_id = nil
    @mon_mutex = nil
    initialize
  end
end
