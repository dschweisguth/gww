Given /^there is a player "([^"]+)"$/ do |username|
  create :person, username: username
end

Given /^there is an? (unfound|unconfirmed|found|revealed) photo$/ do |game_status|
  @photo = create :photo, game_status: game_status
end

Given /^the photo's "([^"]+)" is "([^"]+)"$/ do |attribute, value|
  @photo.update! attribute => value
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

Given /^there is a photo added on "(\d+\/\d+\/\d+)"$/ do |date|
  create :photo, dateadded: Date.parse_utc_time(date)
end

Given /^player "([^"]+)" has a photo$/ do |username|
  create :photo, person: Person.find_by_username(username)
end

Given /^player "([^"]+)" has an? (unfound|unconfirmed|found|revealed) photo$/ do |username, game_status|
  create :photo, person: Person.find_by_username(username), game_status: game_status
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

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, field|
  select value, from: field
end

Then /^the URL should be "([^"]+)"$/ do |uri|
  expect(current_path).to eq(uri)
end

Then /^the "([^"]+)" field should contain "([^"]+)"$/ do |field, value|
  expect(find_field(field).value).to eq(value)
end

Then /^the "([^"]+)" field should be empty$/ do |field|
  expect(find_field(field).value).to be_blank
end

Then /^the "([^"]+)" option "([^"]+)" should be selected$/ do |field, value|
  expect(find("[name=#{field}] option[selected]").text).to eq(value)
end

Then /^the game statuses "([^"]*)" should be selected$/ do |game_statuses|
  expect(find_field('game_status').all('option[selected]').map(&:text)).to match_array(game_statuses.split(','))
end

Then /^I should see an image-only search result for the photo$/ do
  i_should_see_image_only_search_result_for_photo @photo
end

Then /^I should see (\d+) image-only search results?$/ do |result_count|
  expect(all('.image').count).to eq(result_count.to_i)
  expect(all('.text')).to be_empty
end

Then /^I should see an image-only search result for the photo added on "(\d+\/\d+\/\d+)"/ do |date|
  photo = Photo.where(dateadded: Date.parse_utc_time(date)).first
  i_should_see_image_only_search_result_for_photo photo
end

def i_should_see_image_only_search_result_for_photo(photo)
  link = find %Q(a[href="#{url_for_flickr_photo_in_pool photo}"])
  expect(link).to have_css %Q(img[src="#{url_for_flickr_image photo, 'm'}"])
  expect(all('.text')).to be_empty
end

Then /^image-only search result (\d+) should be the photo added on "([^"]+)"$/ do |result_index, date|
  photo = Photo.where(dateadded: Date.parse_utc_time(date)).first
  image_only_search_result_should_be result_index, photo
end

def image_only_search_result_should_be(result_index, photo)
  result = all('.image')[result_index.to_i - 1]
  expect(result).to have_css(%Q(a[href="#{url_for_flickr_photo_in_pool photo}"]))
end

Then /^I should see (\d+) full search results?$/ do |result_count|
  result_count = result_count.to_i
  expect(all('.image').count).to eq(result_count)
  expect(all('.text').count).to eq(result_count)
end

Then /^full search result (\d+) should be player "([^"]+)"'s photo$/ do |result_index, poster_username|
  photo = Person.find_by_username(poster_username).photos.first
  full_search_result_should_be result_index, photo
end

Then /^full search result (\d+) should be player "([^"]+)"'s photo taken on "([^"]+)"$/ do |result_index, poster_username, date|
  photo = Person.find_by_username(poster_username).photos.where(datetaken: Date.parse_utc_time(date)).first
  full_search_result_should_be result_index, photo
end

def full_search_result_should_be(result_index, photo)
  image_only_search_result_should_be result_index, photo
  result = all('.text')[result_index.to_i - 1]
  expect(result.find('h2')).to have_content(photo.title)
  expect(result.find('p')).to have_content(photo.description)
end

Then /^I shouid not see a search result for the photo added on "(\d+\/\d+\/\d+)"/ do |date|
  photo = Photo.where(dateadded: Date.parse_utc_time(date)).first
  expect(all(%Q(a[href="#{url_for_flickr_photo_in_pool photo}"]))).to be_empty
end

Then /^I should see the photo's title$/ do
  expect(all('h2').any? { |h2| h2.has_content?(@photo.title) }).to be_truthy
end

Then /^I should see the photo's title with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  expect(page).to have_content(@photo.title)
  [term1, term2].each do |term|
    expect(all('h2').any? { |h2| h2.has_css?('span[class=matched]', text: term) }).to be_truthy
  end
end

Then /^I should see the photo's description$/ do
  expect(all('p').any? { |p| p.has_content?(@photo.description) }).to be_truthy
end

Then /^I should see the photo's description with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the photo's description"
  [term1, term2].each do |term|
    expect(all('p').any? { |p| p.has_css?('span[class=matched]', text: term) }).to be_truthy
  end
end

Then /^I should see the tag$/ do
  expect(page).to have_css('li', text: @tag.raw)
end

Then /^I should see the tag with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  step "I should see the tag"
  [term1, term2].each do |term|
    expect(all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }).to be_truthy
  end
end

Then(/^I should see a tag with "([^"]*)" highlighted$/) do |term|
  expect(all('li').any? { |li|li.has_css?('span[class=matched]', text: term) }).to be_truthy
end

Then /^I should not see the comment$/ do
  expect(page).to_not have_content(@comment.comment_text)
end

Then /^I should see the comment with "([^"]+)" and "([^"]+)" highlighted$/ do |term1, term2|
  expect(page).to have_content(@comment.comment_text)
  [term1, term2].each do |term|
    expect(page).to have_css('span[class=matched]', text: term)
  end
end

Then(/^I should see "([^"]+)" with "([^"]+)" highlighted$/) do |text, term|
  expect(page).to have_content(text)
  expect(page).to have_css('span[class=matched]', text: term)
end

Then /^I should see player "([^"]+)"'s comment on player "([^"]+)"'s photo$/ do |commenter_username, poster_username|
  comment = Person.find_by_username(poster_username).photos.first.comments.first
  expect(comment.username).to eq(commenter_username)
  expect(page).to have_content(comment.comment_text)
end

Then /^I should see the comment "([^"]+)" on full search result (\d+)$/ do |comment, result_index|
  expect(all('.text')[result_index.to_i - 1]).to have_content(comment)
end

Then /^I should not see the comment "([^"]+)" on full search result (\d+)$/ do |comment, result_index|
  expect(all('.text')[result_index.to_i - 1]).not_to have_content(comment)
end
