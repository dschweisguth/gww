Given /^there is an? ([^"]+) photo$/ do |game_status|
  @photo = create :photo, game_status: game_status
end

Given /^the photo's "([^"]+)" is "([^"]+)"$/ do |attribute, value|
  @photo.update! attribute => value
end

Given /^there is a player "([^"]+)"$/ do |username|
  create :person, username: username
end

Given /^player "([^"]+)" has a photo$/ do |username|
  create :photo, person: Person.find_by_username(username)
end

Given /^player "([^"]+)" has an? "([^"]+)" photo$/ do |username, game_status|
  create :photo, person: Person.find_by_username(username), game_status: game_status
end

Given /^the photo has a tag$/ do
  @tag = create :tag, photo: @photo
end

Given /^the photo has a tag "([^"]+)"$/ do |raw|
  @tag = create :tag, photo: @photo, raw: raw
end

Given /^the photo has a comment$/ do
  @comment = create :comment, photo: @photo
end

Given /^the photo has a comment "([^"]+)"$/ do |comment_text|
  @comment = create :comment, photo: @photo, comment_text: comment_text
end

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, field_identifier|
  select value, from: field_identifier
end

Then /^I should see a search result for the photo$/ do
  link = page.find %Q(a[href="#{url_for_flickr_photo_in_pool @photo}"])
  link.should have_css %Q(img[src="#{url_for_flickr_image @photo, 'm'}"])
end

Then /^I should see search results for (\d+) photos?$/ do |photo_count|
  page.all('a[href^="https://www.flickr.com/photos/"]').count.should == photo_count.to_i
end

Then /^I should see the photo's "([^"]+)"$/ do |attribute|
  page.should have_content(@photo.send attribute)
end

Then /^I should see the tag$/ do
  page.should have_content(@tag.raw)
end

Then /^I should see the comment$/ do
  page.should have_content(@comment.comment_text)
end

Then /^I should not see the comment$/ do
  page.should_not have_content(@comment.comment_text)
end
