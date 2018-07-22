Given /^there is a player "([^"]+)"$/ do |username|
  create :person, username: username
end

Given /^there is a photo$/ do
  @photo = create :photo
end

Given /^there is a Flickr update$/ do
  @flickr_update = create :flickr_update
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

Then /^I should not see "([^"]+)"$/ do |text|
  expect(page).not_to have_content(text)
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^show me the screen$/ do
  save_screenshot 'screenshot.png'
end

Given(/^Capybara\.default_max_wait_time is (\d+\.\d+) s$/) do |default_max_wait_time|
  allow(Capybara).to receive(:default_max_wait_time) { default_max_wait_time.to_f }
end

When(/^I wait_for something that takes (\d+(?:\.\d+)?) s with an interval of (\d+\.\d+) s then the thing happens/) do |time_to_wait, interval|
  start_time = Time.now.to_f
  wait_for(interval.to_f) { Time.now.to_f - start_time > time_to_wait.to_f }
end

When(/^I wait_for something that takes (\d+\.\d+) s with an interval of (\d+\.\d+) s then the thing doesn't happen$/) do |time_to_wait, interval|
  start_time = Time.now.to_f
  expect { wait_for(interval.to_f) { Time.now.to_f - start_time > time_to_wait.to_f } }.to raise_error RuntimeError
end

# Takes a block which returns true when we should stop waiting
def wait_for(interval = 1)
  seconds_waited = 0
  while !yield && seconds_waited < Capybara.default_max_wait_time
    sleep interval
    seconds_waited += interval
  end
  if !yield
    raise "Waited for #{Capybara.default_max_wait_time} seconds but condition did not become true"
  end
end
