Given /^a Flickr update started at "(\d+\/\d+\/\d+ \d+:\d+)" and is still running$/ do |time|
  create :flickr_update, created_at: Time.parse(time).getutc
end
