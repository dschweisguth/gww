Given /^there is a photo$/ do
  @photo = create :photo
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
  tds = page.find('table').all 'td'
  tds[0].text.should == @comment.username
  tds[2].text.should == @comment.comment_text
end

Given /^there is a photo with a comment by the poster$/ do
  @photo = create :photo
  @comment = create :comment, photo: @photo, flickrid: @photo.person.flickrid, username: @photo.person.username
end

Then /^I should see that the photo was revealed by the poster$/ do
  page.should have_content("This photo's location was revealed by ...")
  tds = page.find('table').all 'td'
  tds[0].text.should == @photo.person.username
  tds[2].text.should == @comment.comment_text
end

Then /^I should see that the photo was guessed by the third player$/ do
  page.should have_content("This photo was correctly guessed by ...")
  tds = page.find('table').all 'td'
  tds[0].text.should == @third_player.username
  tds[2].text.should == @comment.comment_text
end

Then /^I should see that the photo was revealed by the poster with the text "([^"]+)"$/ do |text|
  page.should have_content("This photo's location was revealed by ...")
  tds = page.find('table').all 'td'
  tds[0].text.should == @photo.person.username
  tds[2].text.should == text
end

Then /^I should see that the photo was guessed by the third player with the text "([^"]+)"$/ do |text|
  page.should have_content("This photo was correctly guessed by ...")
  tds = page.find('table').all 'td'
  tds[0].text.should == @third_player.username
  tds[2].text.should == text
end

Then /^I should not see any photos$/ do
  page.all('td').should be_empty
end
