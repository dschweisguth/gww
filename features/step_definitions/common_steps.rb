Given /^there is a photo$/ do
  @photo = create :photo
end

Given /^there is a Flickr update$/ do
  create :flickr_update
end

Given /^there is a score report$/ do
  create :score_report
end

When /^I go to (.*)$/ do |page_name|
  visit path_to(page_name)
end

When /^I follow the "([^"]+)" link$/ do |text|
  click_link text
end

When /^I press the "([^"]+)" button$/ do |label|
  click_button label
end

When /^I fill in "([^"]+)" with "([^"]+)"$/ do |field, text|
  fill_in field, with: text
end

Then /^I should be on (.*)$/ do |page_name|
  URI.parse(current_url).path.should == path_to(page_name)
end

Then /^I should see "([^"]+)"$/ do |text|
  page.should have_content(text)
end

Then /^show me the page$/ do
  save_and_open_page
end
