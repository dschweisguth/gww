Feature: Photos
  As a player
  I want to search for and sort photos by various criteria
  So that I can find the few photos I'm interested in among the thousands in the database

  @javascript
  Scenario: Player searches for all photos
    Given there is a Flickr update
    And there is a score report
    And there is a photo
    When I go to the home page
    And I follow the "Search for photos" link
    Then I should see a search result for the photo

  @javascript
  Scenario: Player searches for unfound or unconfirmed photos
    Given there is an unfound photo
    And there is an unconfirmed photo
    And there is a found photo
    And there is a revealed photo
    When I go to the photos search page
    And I select "unfound" from "game_status"
    And I select "unconfirmed" from "game_status"
    And I press the "Search" button
    Then the game statuses "unfound,unconfirmed" should be selected
    And I should see 2 search results

  @javascript
  Scenario: Player searches for a given user's photos
    Given there is a player "abcdefgh"
    And player "abcdefgh" has a photo
    And there is a player "ijklmnop"
    And player "ijklmnop" has a photo
    When I go to the photos search page
    And I autoselect "abcdefgh (1)" from the "#username" field
    And I press the "Search" button
    Then the "username" field should contain "abcdefgh"
    And I should see 1 search result

  @javascript
  Scenario: Player searches for a given user's unfound or unconfirmed photos
    Given there is a player "abcdefgh"
    And player "abcdefgh" has a photo
    And player "abcdefgh" has a "found" photo
    When I go to the photos search page
    And I select "unfound" from "game_status"
    And I select "unconfirmed" from "game_status"
    And I autoselect "abcdefgh (1)" from the "#username" field
    And I press the "Search" button
    Then the game statuses "unfound,unconfirmed" should be selected
    And the "username" field should contain "abcdefgh"
    And I should see 1 search result

  @javascript
  Scenario: Player searches for a string which matches only the title
    Given there is a photo
    And the photo's "title" is "Fort Point Title"
    And the photo has a tag
    And the photo has a comment
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then the "text" field should contain "Fort Point"
    And I should see 1 search result
    And I should see the photo's title with "Fort" and "Point" highlighted
    And I should see the photo's description
    And I should see the tag
    But I should not see the comment

  # This scenario is necessary because there's no way to tell a highlight in a comment from one in a different field
  @javascript
  Scenario: Player searches for a string which matches only a comment
    Given there is a photo
    And the photo has a comment "Fort Point Comment"
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then the "text" field should contain "Fort Point"
    And I should see 1 search result
    And I should see the photo's title
    And I should see the photo's description
    And I should see the comment with "Fort" and "Point" highlighted

  @javascript
  Scenario: Player searches for a string which matches every field
    Given there is a photo
    And the photo's "title" is "Fort Point Title"
    And the photo's "description" is "Fort Point Title"
    And the photo has a tag "Fort Point Tag"
    And the photo has a comment "Fort Point Comment"
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then the "text" field should contain "Fort Point"
    And I should see 1 search result
    And I should see the photo's title with "Fort" and "Point" highlighted
    And I should see the photo's description with "Fort" and "Point" highlighted
    And I should see the tag with "Fort" and "Point" highlighted
    And I should see the comment with "Fort" and "Point" highlighted

  @javascript
  Scenario: Player searches for a two-word string which matches two different tags
    Given there is a photo
    And the photo has a tag "Fort Tag"
    And the photo has a tag "Point Tag"
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then the "text" field should contain "Fort Point"
    And I should see a tag with "Fort" highlighted
    And I should see a tag with "Point" highlighted

  @javascript
  Scenario: Player searches for a comma-separated string which matches different comments
    Given there is a photo
    And the photo has a comment "It's a super-spectacular day"
    And the photo has a comment "I thought gentrification meant men dressing themselves carefully"
    When I go to the photos search page
    And I fill in "text" with "spectacular, gentrification"
    And I press the "Search" button
    Then the "text" field should contain "spectacular, gentrification"
    Then I should see "It's a super-spectacular day" with "spectacular" highlighted
    And I should see "I thought gentrification meant men dressing themselves carefully" with "gentrification" highlighted

  @javascript
  Scenario: Player searches in a date range
    Given there is a photo posted on "12/31/13"
    Given there is a photo posted on "1/1/14"
    And there is a photo posted on "1/2/14"
    And there is a photo posted on "1/3/14"
    When I go to the photos search page
    And I fill in "from_date" with "1/1/14"
    And I fill in "to_date" with "1/2/14"
    And I press the "Search" button
    Then the "from_date" field should contain "1/1/14"
    And the "to_date" field should contain "1/2/14"
    And I shouid not see a search result for the photo posted on "12/31/13"
    But I should see a search result for the photo posted on "1/1/14"
    And I should see a search result for the photo posted on "1/2/14"
    But I shouid not see a search result for the photo posted on "1/3/14"

  @javascript
  Scenario: Player searches with invalid dates
    Given there is a photo
    When I go to the photos search page
    And I fill in "from_date" with "invalid"
    And I fill in "to_date" with "invalid"
    And I press the "Search" button
    Then the URL should not contain "from-date"
    And the URL should not contain "to-date"
    And the date fields should be empty
    And I should see 1 search result

  @javascript
  Scenario: Player searches in a backwards date range
    Given there is a photo
    When I go to the photos search page
    And I fill in "from_date" with "1/2/14"
    And I fill in "to_date" with "1/1/14"
    And I press the "Search" button
    Then the URL should not contain "from-date"
    And the URL should not contain "to-date"
    And the date fields should be empty
    And I should see 1 search result

  @javascript
  Scenario: Player searches for activity
    Given there is a player "abcdefgh"
    And player "abcdefgh" took a photo on "1/1/14"
    And there is a player "ijklmnop"
    And player "ijklmnop" took a photo on "1/2/14"
    And player "abcdefgh" commented "Today is 1/1/14" on player "ijklmnop"'s photo on "1/3/14"
    When I go to the photos search page
    And I select "Activity" from "did"
    And I fill in "username" with "abcdefgh"
    And I press the "Search" button
    Then the action "Activity" should be selected
    And I should see 2 search results
    And search result 1 should be player "ijklmnop"'s photo
    And search result 2 should be player "abcdefgh"'s photo
    And I should see player "abcdefgh"'s comment on player "ijklmnop"'s photo

  @javascript
  Scenario: Player finds different comments by the same user
    Given there is a player "abcdefgh"
    And player "abcdefgh" has a photo
    And there is a player "ijklmnop"
    And player "ijklmnop" commented "Today is 1/1/14" on player "abcdefgh"'s photo on "1/1/14"
    And player "ijklmnop" commented "Today is 1/2/14" on player "abcdefgh"'s photo on "1/2/14"
    When I go to the photos search page
    And I select "Activity" from "did"
    And I fill in "username" with "ijklmnop"
    And I press the "Search" button
    Then I should see 2 search results
    And I should see the comment "Today is 1/2/14" on search result 1
    But I should not see the comment "Today is 1/1/14" on search result 1
    And I should see the comment "Today is 1/1/14" on search result 2
    But I should not see the comment "Today is 1/2/14" on search result 2

  @javascript
  Scenario: Player searches for activity in a date range
    Given there is a player "abcdefgh"
    And there is a player "ijklmnop"
    And player "abcdefgh" took a photo on "1/1/14"
    And player "abcdefgh" took a photo on "1/2/14"
    And player "abcdefgh" took a photo on "1/4/14"
    And player "ijklmnop" took a photo on "1/1/14"
    And player "abcdefgh" commented "Today is 1/1/14" on player "ijklmnop"'s photo on "1/1/14"
    And player "abcdefgh" commented "Today is 1/3/14" on player "ijklmnop"'s photo on "1/3/14"
    And player "abcdefgh" commented "Today is 1/4/14" on player "ijklmnop"'s photo on "1/4/14"
    When I go to the photos search page
    And I select "Activity" from "did"
    And I fill in "username" with "abcdefgh"
    And I fill in "from_date" with "1/2/14"
    And I fill in "to_date" with "1/3/14"
    And I press the "Search" button
    Then I should see 2 search results
    And search result 1 should be player "ijklmnop"'s photo
    And I should see the comment "Today is 1/3/14" on search result 1
    And search result 2 should be player "abcdefgh"'s photo taken on "1/2/14"

  @javascript
  Scenario: Player fills in fields incompatible with searching by activity
    When I go to the photos search page
    And I select "Activity" from "did"
    And I fill in "text" with "Fort Point"
    And I select "unfound" from "game_status"
    And I select "Date added" from "sorted_by"
    And I press the "Search" button
    Then the URL should not contain "text"
    And the "text" field should be empty
    And the URL should not contain "text"
    And no "game_status" field should be selected
    And the order "date-taken" should be selected
