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

Then /^I should see the photo's title$/ do
  page.all('h2').any? { |h2| h2.has_content?(@photo.title) }.should be_truthy
end

Then /^I should see the photo's description$/ do
  page.all('p').any? { |p| p.has_content?(@photo.description) }.should be_truthy
end

Then /^I should see the photo's title with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  page.should have_content(@photo.title)
  [term1, term2].each do |term|
    page.all('h2').any? { |h2| h2.has_css?('span[class=matched]', text: term) }.should be_truthy
  end
end

Then /^I should see the photo's description with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the photo's description"
  [term1, term2].each do |term|
    page.all('p').any? { |p| p.has_css?('span[class=matched]', text: term) }.should be_truthy
  end
end

Then /^I should see the tag$/ do
  page.should have_css('li', text: @tag.raw)
end

Then /^I should see the tag with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the tag"
  [term1, term2].each do |term|
    page.all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }.should be_truthy
  end
end

Then /^I should see the comment with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  page.should have_content(@comment.comment_text)
  [term1, term2].each do |term|
    page.should have_css('span[class=matched]', text: term)
  end
end

Then /^I should not see the comment$/ do
  page.should_not have_content(@comment.comment_text)
end


Then(/^I should see "([^"]+)" with "([^"]+)" highlighted$/) do |text, term|
  page.should have_content(text)
  page.should have_css('span[class=matched]', text: term)
end


Then(/^I should see a tag with "([^"]*)" highlighted$/) do |term|
  page.all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }.should be_truthy
end
