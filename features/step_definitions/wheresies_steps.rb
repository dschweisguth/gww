Given /^scores were reported this year$/ do
  create :score_report, created_at: Time.now.end_of_year
end

Given /^there is a player "([^"]*)" with a guess from a previous year$/ do |username|
  player = create :person, username: username
  create :guess, person: player, commented_at: Time.now.year - 1
end

Given /^there is a player "([^"]*)" with no guesses from previous years$/ do |username|
  create :person, username: username
end

Given /^the player "([^"]*)" scored (\d+) points? this year$/ do |username, score|
  score.to_i.times { create :guess, person: Person.find_by_username(username) }
end

Given /^the player "([^"]*)" posted (\d+) photos? this year$/ do |username, photo_count|
  photo_count.to_i.times { create :photo, person: Person.find_by_username(username) }
end

Given /^a player "([^"]*)" posted a photo with (\d+) views?$/ do |username, views|
  player = create :person, username: username
  create :photo, person: player, views: views.to_i
end

Given /^a player "([^"]*)" posted a photo with (\d+) faves?$/ do |username, faves|
  player = create :person, username: username
  create :photo, person: player, faves: faves.to_i
end

Given /^a player "([^"]*)" posted a photo with a comment$/ do |username|
  player = create :person, username: username
  photo = create :photo, person: player
  create :comment, photo: photo
end

Given /^a player "([^"]*)" guessed a photo after (\d+) years?$/ do |username, years|
  player = create :person, username: username
  photo = create :photo, dateadded: years.to_i.years.ago
  create :guess, person: player, photo: photo
end

Given /^a player "([^"]*)" guessed a photo after (\d+) seconds?$/ do |username, seconds|
  player = create :person, username: username
  photo = create :photo, dateadded: seconds.to_i.seconds.ago
  create :guess, person: player, photo: photo
end

When /^I click on this year$/ do
  click_link Time.now.year
end

Then /^the headline should say that the results are preliminary$/ do
  page.should have_css 'h1', text: "#{Time.now.year} Wheresies (preliminary)"
end

Then /^the player "([^"]*)" should be first on the rookies' most-points list with (\d+) points$/ do |username, points|
  most_points_list = page.all('body > div > div > div')[0]
  most_points_list.should have_css 'h3', text: "Most points in #{Time.now.year}"
  tds = most_points_list.all 'td'
  tds[1].text.should == username
  tds[2].text.should == points
end

Then /^the player "([^"]*)" should be first on the rookies' most-posts list with (\d+) posts$/ do |username, posts|
  most_posts_list = page.all('body > div > div > div')[1]
  most_posts_list.should have_css 'h3', text: "Most posts in #{Time.now.year}"
  tds = most_posts_list.all 'td'
  tds[1].text.should == username
  tds[2].text.should == posts
end

Then /^the player "([^"]*)" should be first on the veterans' most-points list with (\d+) points$/ do |username, points|
  most_points_list = page.all('body > div > div > div')[2]
  most_points_list.should have_css 'h3', text: "Most points in #{Time.now.year}"
  tds = most_points_list.all 'td'
  tds[1].text.should == username
  tds[2].text.should == points
end

Then /^the player "([^"]*)" should be first on the veterans' most-posts list with (\d+) posts$/ do |username, posts|
  most_posts_list = page.all('body > div > div > div')[3]
  most_posts_list.should have_css 'h3', text: "Most posts in #{Time.now.year}"
  tds = most_posts_list.all 'td'
  tds[1].text.should == username
  tds[2].text.should == posts
end

Then /^the player "([^"]*)" should be first on the most-viewed list with (\d+) views$/ do |username, views|
  most_viewed_list = page.all('body > div > div')[2]
  most_viewed_list.should have_css 'h2', text: "Most-viewed photos of #{Time.now.year}"
  tds = most_viewed_list.all 'td'
  tds[2].text.should == username
  tds[6].text.should == views
end

Then /^the player "([^"]*)" should be first on the most-faved list with (\d+) faves$/ do |username, faves|
  most_faved_list = page.all('body > div > div')[3]
  most_faved_list.should have_css 'h2', text: "Most-faved photos of #{Time.now.year}"
  tds = most_faved_list.all 'td'
  tds[2].text.should == username
  tds[6].text.should == faves
end

Then /^the player "([^"]*)" should be first on the most-commented list with (\d+) comments?$/ do |username, comments|
  most_commented_list = page.all('body > div > div')[4]
  most_commented_list.should have_css 'h2', text: "Most-commented photos of #{Time.now.year}"
  tds = most_commented_list.all 'td'
  tds[2].text.should == username
  tds[6].text.should == comments
end

Then /^the player "([^"]*)" should be first on the longest-lasting list with a photo guessed after (\d+) years$/ do |username, years|
  longest_lasting_list = page.all('body > div > table')[0]
  tds_in_first_row = longest_lasting_list.all('tr')[1].all 'td'
  tds_in_first_row[2].text.should == username
  tds_in_first_row.last.text.should == "#{years} year#{if years.to_i != 1 then 's' end}"
end

# TODO Dave this test failed once; veteran was first instead of fastest. Deflake it somehow.
Then /^the player "([^"]*)" should be first on the fastest-guessed list with a photo guessed after (\d+) seconds?$/ do |username, seconds|
  fastest_guessed_list = page.all('body > div > table')[1]
  tds_in_first_row = fastest_guessed_list.all('tr')[1].all 'td'
  tds_in_first_row[2].text.should == username
  # Allow one more second than specified in case the test runs slowly
  [ "#{seconds} second#{if seconds.to_i != 1 then 's' end}", "#{seconds.to_i + 1} seconds" ].should include(tds_in_first_row.last.text)
end
