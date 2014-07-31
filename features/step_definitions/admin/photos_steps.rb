Given /^updating a photo from Flickr does nothing$/ do
  # noinspection RubyArgCount
  stub(FlickrUpdater).update_photo { nil }
end

Given /^there is an inaccessible photo$/ do
  @photo = create :photo, seen_at: 1.year.ago
end

Given /^updating a photo from Flickr returns an error$/ do
  # noinspection RubyArgCount
  stub(FlickrUpdater).update_photo { raise FlickrService::FlickrReturnedAnError.new stat: 'fail', code: 1, msg: "Photo not found" }
end

Given /^getting a person's attributes from Flickr returns what we'd expect given what's in the database$/ do
  # noinspection RubyArgCount
  stub(FlickrUpdater).person_attributes do |flickrid|
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
  find('#username_form').fill_in 'username', with: @third_player.username
end

Then /^I should see that the photo was guessed by the commenter$/ do
  page.should have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  tds[0].text.should == @comment.username
  tds[2].text.should == @comment.comment_text
end

Given /^there is a photo with a comment by the poster$/ do
  @photo = create :photo
  @comment = create :comment, photo: @photo, flickrid: @photo.person.flickrid, username: @photo.person.username
end

Then /^I should see that the photo was revealed by the poster$/ do
  page.should have_content("This photo's location was revealed by ...")
  tds = find('table').all 'td'
  tds[0].text.should == @photo.person.username
  tds[2].text.should == @comment.comment_text
end

Then /^I should see that the photo was guessed by the third player$/ do
  page.should have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  tds[0].text.should == @third_player.username
  tds[2].text.should == @comment.comment_text
end

Then /^I should see that the photo was revealed by the poster with the text "([^"]+)"$/ do |text|
  page.should have_content("This photo's location was revealed by ...")
  tds = find('table').all 'td'
  tds[0].text.should == @photo.person.username
  tds[2].text.should == text
end

Then /^I should see that the photo was guessed by the third player with the text "([^"]+)"$/ do |text|
  page.should have_content("This photo was correctly guessed by ...")
  tds = find('table').all 'td'
  tds[0].text.should == @third_player.username
  tds[2].text.should == text
end

Then /^I should not see any photos$/ do
  all('td').should be_empty
end

Then /^I should see the error$/ do
  page.should have_content "stat = 'fail', code = 1, msg = \"Photo not found\""
end
