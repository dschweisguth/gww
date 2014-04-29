Given /^there is an? ([^"]+) photo$/ do |game_status|
  create :photo, game_status: game_status
end

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, field_identifier|
  select value, from: field_identifier
end

Then /^I should see a search result for the photo$/ do
  link = page.find %Q(a[href="#{url_for_flickr_photo_in_pool @photo}"])
  link.should have_css %Q(img[src="#{url_for_flickr_image @photo, 'm'}"])
end

Then /^I should see search results for (\d+) photos$/ do |photo_count|
  page.all('a[href^="http://www.flickr.com/photos/"]').count.should == photo_count.to_i
end
