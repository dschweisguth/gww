Given /^a Flickr update started at "(\d+\/\d+\/\d+ \d+:\d+)" and is still running$/ do |time|
  create :flickr_update, created_at: Time.parse(time).getutc
end

Given /^there has been enough activity for the home page to be displayed without error$/ do
  step "there is a Flickr update"
  step "there is a score report"
end
