class FlickrUpdate < ActiveRecord::Base
  validates_presence_of :member_count
  validates_numericality_of :member_count, :only_integer => true,
    :greater_than_or_equal_to => 0
  attr_readonly :member_count

  def self.latest
    order("id desc").first
  end

  def self.create_before_and_update_after
    group_info = FlickrCredentials.groups_get_info :group_id => FlickrCredentials::GROUP_ID
    member_count = group_info['group'][0]['members'][0]
    update = FlickrUpdate.create! :member_count => member_count
    return_value = yield
    update.update_attribute :completed_at, Time.now.getutc
    return_value
  end

end
