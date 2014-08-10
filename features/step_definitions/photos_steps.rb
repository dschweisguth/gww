Given /^there is an? (unfound|unconfirmed|found|revealed) photo$/ do |game_status|
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

Given /^there is a photo posted on "(\d+\/\d+\/\d+)"$/ do |date|
  create :photo, dateadded: Date.parse_utc_time(date)
end

Given /^player "([^"]+)" took a photo on "(\d+\/\d+\/\d+)"$/ do |poster_username, date|
  create :photo, person: Person.find_by_username(poster_username), datetaken: Date.parse_utc_time(date)
end

Given /^player "([^"]+)" commented "([^"]+)" on player "([^"]+)"'s photo on "([^"]+)"$/ do |commenter_username, comment_text, poster_username, date|
  commenter_username = Person.find_by_username commenter_username
  create :comment, photo: Person.find_by_username(poster_username).photos.first,
    flickrid: commenter_username.flickrid, username: commenter_username.username,
    comment_text: comment_text, commented_at: Date.parse_utc_time(date)
end

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, field_identifier|
  select value, from: field_identifier
end

Then /^I should see a search result for the photo$/ do
  i_should_see_search_result_for_photo @photo
end

Then /^I should see (\d+) search results?$/ do |result_count|
  all('a[href^="https://www.flickr.com/photos/"]').count.should == result_count.to_i
end

Then /^the action "([^"]+)" should be selected$/ do |action|
  find('[name=did] option[selected]').text.should == action
end

Then /^the game statuses "([^"]+)" should be selected$/ do |game_statuses|
  find_field('game_status').all('option[selected]').map(&:text).should =~ game_statuses.split(',')
end

Then /^the "([^"]+)" field should contain "([^"]+)"$/ do |field, value|
  find_field(field).value.should == value
end

Then /^I should see the photo's title$/ do
  all('h2').any? { |h2| h2.has_content?(@photo.title) }.should be_truthy
end

Then /^I should see the photo's description$/ do
  all('p').any? { |p| p.has_content?(@photo.description) }.should be_truthy
end

Then /^search result (\d+) should be player "([^"]+)"'s photo$/ do |result_index, poster_username|
  photo = Person.find_by_username(poster_username).photos.first
  result_should_be result_index, photo
end

Then /^search result (\d+) should be player "([^"]+)"'s photo taken on "([^"]+)"$/ do |result_index, poster_username, date|
  photo = Person.find_by_username(poster_username).photos.where(datetaken: Date.parse_utc_time(date)).first
  result_should_be result_index, photo
end

def result_should_be(result_index, photo)
  result = all('.text')[result_index.to_i - 1]
  result.find('h2').should have_content(photo.title)
  result.find('p').should have_content(photo.description)
end

Then /^I should see the photo's title with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  page.should have_content(@photo.title)
  [term1, term2].each do |term|
    all('h2').any? { |h2| h2.has_css?('span[class=matched]', text: term) }.should be_truthy
  end
end

Then /^I should see the photo's description with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the photo's description"
  [term1, term2].each do |term|
    all('p').any? { |p| p.has_css?('span[class=matched]', text: term) }.should be_truthy
  end
end

Then /^I should see the tag$/ do
  page.should have_css('li', text: @tag.raw)
end

Then /^I should see the tag with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the tag"
  [term1, term2].each do |term|
    all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }.should be_truthy
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
  all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }.should be_truthy
end

Then /^I should see a search result for the photo posted on "(\d+\/\d+\/\d+)"/ do |date|
  photo = Photo.where(dateadded: Date.parse_utc_time(date)).first
  i_should_see_search_result_for_photo photo
end

def i_should_see_search_result_for_photo(photo)
  link = find %Q(a[href="#{url_for_flickr_photo_in_pool photo}"])
  link.should have_css %Q(img[src="#{url_for_flickr_image photo, 'm'}"])
end

Then /^I shouid not see a search result for the photo posted on "(\d+\/\d+\/\d+)"/ do |date|
  photo = Photo.where(dateadded: Date.parse_utc_time(date)).first
  all(%Q(a[href="#{url_for_flickr_photo_in_pool photo}"])).should be_empty
end

Then /^the URL should not contain "([^"]+)"$/ do |field|
  current_path.should_not include(field)
end

Then /^the "([^"]+)" field should be empty$/ do |field|
  find_field(field).value.should be_blank
end

Then /^no "([^"]+)" field should be selected$/ do |field|
  find_field(field).all('option[selected]').should be_empty
end

Then /^the date fields should be empty$/ do
  %w(to_date from_date).each { |field| find_field(field).value.should be_blank }
end

Then /^I should see player "([^"]+)"'s comment on player "([^"]+)"'s photo$/ do |commenter_username, poster_username|
  comment = Person.find_by_username(poster_username).photos.first.comments.first
  comment.username.should == commenter_username
  page.should have_content(comment.comment_text)
end

Then /^I should see the comment "([^"]+)" on search result (\d+)$/ do |comment, result_index|
  all('.text')[result_index.to_i - 1].should have_content(comment)
end

Then /^I should not see the comment "([^"]+)" on search result (\d+)$/ do |comment, result_index|
  all('.text')[result_index.to_i - 1].should_not have_content(comment)
end
