Given /^scores were reported this year$/ do
  create :score_report, created_at: Time.now.end_of_year
end

Given /^there is a player "([^"]*)" with a guess from a previous year$/ do |username|
  player = create :person, username: username
  create :guess, person: player, commented_at: Time.now - 1.year
end

Given /^there is a player "([^"]*)" with no guesses from previous years$/ do |username|
  create :person, username: username
end

Given /^the player "([^"]*)" scored (\d+) points? this year$/ do |username, score|
  score.times do
    photo = create :photo, dateadded: 1.day.ago # prevent these guesses from showing up on the fastest-guessed list
    create :guess, person: Person.find_by_username(username), photo: photo
  end
end

Given /^the player "([^"]*)" posted (\d+) photos? this year$/ do |username, photo_count|
  photo_count.times { create :photo, person: Person.find_by_username(username) }
end

Given /^a player "([^"]*)" posted a photo with (\d+) views?$/ do |username, views|
  player = create :person, username: username
  create :photo, person: player, views: views
end

Given /^a player "([^"]*)" posted a photo with (\d+) faves?$/ do |username, faves|
  player = create :person, username: username
  create :photo, person: player, faves: faves
end

Given /^a player "([^"]*)" posted a photo with a comment$/ do |username|
  player = create :person, username: username
  photo = create :photo, person: player
  create :comment, photo: photo
end

Given /^a player "([^"]*)" guessed a photo after (\d+) years?$/ do |username, years|
  player = create :person, username: username
  photo = create :photo, dateadded: years.years.ago
  create :guess, person: player, photo: photo
end

Given /^a player "([^"]*)" guessed a photo after (\d+) seconds?$/ do |username, seconds|
  player = create :person, username: username
  photo = create :photo, dateadded: seconds.seconds.ago
  create :guess, person: player, photo: photo
end

When /^I click on this year$/ do
  click_link Time.now.year.to_s
end

Then /^the headline should say that the results are preliminary$/ do
  expect(page).to have_css 'h1', text: "#{Time.now.year} Wheresies (preliminary)"
end

Then /^the player "([^"]*)" should be first on the rookies' most-points list with (\d+) points$/ do |username, points|
  most_points_list = all('body > div > div > div')[0]
  expect(most_points_list).to have_css 'h3', text: "Most points in #{Time.now.year}"
  tds = most_points_list.all 'td'
  expect(tds[1].text).to eq(username)
  expect(tds[2].text).to eq(points.to_s)
end

Then /^the player "([^"]*)" should be first on the rookies' most-posts list with (\d+) posts$/ do |username, posts|
  most_posts_list = all('body > div > div > div')[1]
  expect(most_posts_list).to have_css 'h3', text: "Most posts in #{Time.now.year}"
  tds = most_posts_list.all 'td'
  expect(tds[1].text).to eq(username)
  expect(tds[2].text).to eq(posts.to_s)
end

Then /^the player "([^"]*)" should be first on the veterans' most-points list with (\d+) points$/ do |username, points|
  most_points_list = all('body > div > div > div')[2]
  expect(most_points_list).to have_css 'h3', text: "Most points in #{Time.now.year}"
  tds = most_points_list.all 'td'
  expect(tds[1].text).to eq(username)
  expect(tds[2].text).to eq(points.to_s)
end

Then /^the player "([^"]*)" should be first on the veterans' most-posts list with (\d+) posts$/ do |username, posts|
  most_posts_list = all('body > div > div > div')[3]
  expect(most_posts_list).to have_css 'h3', text: "Most posts in #{Time.now.year}"
  tds = most_posts_list.all 'td'
  expect(tds[1].text).to eq(username)
  expect(tds[2].text).to eq(posts.to_s)
end

Then /^the player "([^"]*)" should be first on the most-viewed list with (\d+) views$/ do |username, views|
  most_viewed_list = all('body > div > div')[2]
  expect(most_viewed_list).to have_css 'h2', text: "Most-viewed photos of #{Time.now.year}"
  tds = most_viewed_list.all 'td'
  expect(tds[2].text).to eq(username)
  expect(tds[6].text).to eq(views.to_s)
end

Then /^the player "([^"]*)" should be first on the most-faved list with (\d+) faves$/ do |username, faves|
  most_faved_list = all('body > div > div')[3]
  expect(most_faved_list).to have_css 'h2', text: "Most-faved photos of #{Time.now.year}"
  tds = most_faved_list.all 'td'
  expect(tds[2].text).to eq(username)
  expect(tds[6].text).to eq(faves.to_s)
end

Then /^the player "([^"]*)" should be first on the most-commented list with (\d+) comments?$/ do |username, comments|
  most_commented_list = all('body > div > div')[4]
  expect(most_commented_list).to have_css 'h2', text: "Most-commented photos of #{Time.now.year}"
  tds = most_commented_list.all 'td'
  expect(tds[2].text).to eq(username)
  expect(tds[6].text).to eq(comments.to_s)
end

Then /^the player "([^"]*)" should be first on the longest-lasting list with a photo guessed after (\d+) years$/ do |username, years|
  longest_lasting_list = all('body > div > table')[0]
  tds_in_first_row = longest_lasting_list.all('tr')[1].all 'td'
  expect(tds_in_first_row[2].text).to eq(username)
  expect(tds_in_first_row.last.text).to eq("#{years} years")
end

Then /^the player "([^"]*)" should be first on the fastest-guessed list with a photo guessed after 1 second$/ do |username|
  fastest_guessed_list = all('body > div > table')[1]
  tds_in_first_row = fastest_guessed_list.all('tr')[1].all 'td'
  expect(tds_in_first_row[2].text).to eq(username)
  expect(tds_in_first_row.last.text).to eq("1 second")
end
