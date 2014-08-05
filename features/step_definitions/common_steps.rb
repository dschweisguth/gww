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

# Warning: only uses the first character of the text. Could be extended to use a specified number.
When /^I autoselect "([^"]+)" from the "([^"]+)" field$/ do |text, field|
  find(field).native.send_keys text[0]
  wait_for { all('a', text: text).any? }
  find('a', text: text).click
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

Then /^show me the screen$/ do
  save_screenshot 'screenshot.png'
end

# Takes a block which returns true when we should stop waiting
def wait_for(delay = 1)
  seconds_waited = 0
  while ! yield && seconds_waited < Capybara.default_wait_time
    sleep delay
    seconds_waited += 1
  end
  raise "Waited for #{Capybara.default_wait_time} seconds but condition did not become true" unless yield
end
