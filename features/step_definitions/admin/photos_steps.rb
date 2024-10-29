Given /^updating a photo from Flickr does nothing$/ do
  allow(FlickrUpdateJob::PhotoUpdater).to receive(:update) { nil }
end

Given /^there is an inaccessible photo$/ do
  @photo = create :photo, seen_at: 1.year.ago
end

Given /^updating a photo from Flickr returns an error$/ do
  allow(FlickrUpdateJob::PhotoUpdater).to receive(:update) do
    raise FlickrService::FlickrReturnedAnError.new stat: 'fail', code: 1, msg: "Photo not found"
  end
end

Given /^getting a person's attributes from Flickr returns what we'd expect given what's in the database$/ do
  allow(FlickrUpdateJob::PersonUpdater).to receive(:attributes) do |flickrid|
    source = Person.find_by_flickrid(flickrid) || Comment.find_by_flickrid(flickrid)
    { username: source.username, pathalias: source.respond_to?(:pathalias) ? source.pathalias : source.username }
  end
end

Given /^there is a photo with a comment by another player$/ do
  @comment = create :comment
  @photo = @comment.photo
end

Given /^there is a third player$/ do
  @third_player = create :person
end

When /^I enter the third player's username$/ do
  find_by_id('username_form').fill_in 'username', with: @third_player.username
end

Then /^I should see that the photo was guessed by the commenter$/ do
  expect(page).to have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  expect(tds[0].text).to eq(@comment.username)
  expect(tds[2].text).to eq(@comment.comment_text)
end

Given /^there is a photo with a comment by the poster$/ do
  @photo = create :photo
  @comment = create :comment, photo: @photo, flickrid: @photo.person.flickrid, username: @photo.person.username
end

Then /^I should see that the photo was revealed by the poster$/ do
  expect(page).to have_content("This photo's location was revealed by ...")
  tds = find('table').all 'td'
  expect(tds[0].text).to eq(@photo.person.username)
  expect(tds[2].text).to eq(@comment.comment_text)
end

Then /^I should see that the photo was guessed by the third player$/ do
  expect(page).to have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  expect(tds[0].text).to eq(@third_player.username)
  expect(tds[2].text).to eq(@comment.comment_text)
end

Then /^I should see that the photo was revealed by the poster with the text "([^"]+)"$/ do |text|
  expect(page).to have_content("This photo's location was revealed by ...")
  tds = find('table').all 'td'
  expect(tds[0].text).to eq(@photo.person.username)
  expect(tds[2].text).to eq(text)
end

Then /^I should see that the photo was guessed by the third player with the text "([^"]+)"$/ do |text|
  expect(page).to have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  expect(tds[0].text).to eq(@third_player.username)
  expect(tds[2].text).to eq(text)
end

Then /^I should not see any photos$/ do
  expect(all('td')).to be_empty
end

Then /^I should see the error$/ do
  expect(page).to have_content "stat = 'fail', code = 1, msg = \"Photo not found\""
end
