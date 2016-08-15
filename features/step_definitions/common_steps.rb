Given /^there is a player "([^"]+)"$/ do |username|
  create :person, username: username
end

Given /^there is a photo$/ do
  @photo = create :photo
end

Given /^there is a Flickr update$/ do
  create :flickr_update
end

Given /^there is a score report$/ do
  create :score_report
end

Given /^there has been enough activity for the home page to be displayed without error$/ do
  step "there is a Flickr update"
  step "there is a score report"
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

# Warning: only uses the first character of the text. Could be extended to use a specified number.
When /^I autoselect "([^"]+)" from the "([^"]+)" field$/ do |text, field|
  find_field(field).native.send_keys text[0]
  wait_for { all('.ui-menu-item', text: text).any? }
  find('.ui-menu-item', text: text).click
end

Then /^I should be on (.*)$/ do |page_name|
  expect(URI.parse(current_url).path).to eq(path_to(page_name))
end

Then /^I should see "([^"]+)"$/ do |text|
  expect(page).to have_content(text)
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^show me the screen$/ do
  save_screenshot 'screenshot.png'
end

# Takes a block which returns true when we should stop waiting
def wait_for(delay = 1)
  seconds_waited = 0
  while !yield && seconds_waited < Capybara.default_max_wait_time
    sleep delay
    seconds_waited += 1
  end
  raise "Waited for #{Capybara.default_max_wait_time} seconds but condition did not become true" unless yield
end
