When /^I follow the '([^']+)' link$/ do |text|
  click_link text
end

Then /^I should see '([^']+)'$/ do |text|
  expect(page).to have_content(text)
end

Then /^I should see a link "([^"]+)" to "(.*?)"$/ do |text, href|
  expect(page).to have_css(%Q(a[href="#{href}"]), text: text)
end

Given /^there is a guessed photo$/ do
  @photo = create :guessed_photo
end

Then /^I should see "([^"]*)" in a new window$/ do |text|
  within_window(windows.last) do
    expect(page).to have_content(text)
  end
end
