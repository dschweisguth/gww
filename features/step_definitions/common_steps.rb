Given /^there is a Flickr update$/ do
  create :flickr_update
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

Then /^show me the page$/ do
  save_and_open_page
end
