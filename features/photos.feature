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
    Then I should see search results for 2 photos

  @javascript
  Scenario: Player searches for a given user's photos
    Given there is a player "abcdefgh"
    And player "abcdefgh" has a photo
    And there is a player "ijklmnop"
    And player "ijklmnop" has a photo
    When I go to the photos search page
    And I press the keys "a" in the "#username" field
    And I wait until an "abcdefgh (1)" menu item appears
    And I click the "abcdefgh (1)" menu item
    And I press the "Search" button
    Then I should see search results for 1 photo

  @javascript
  Scenario: Player searches for a given user's unfound or unconfirmed photos
    Given there is a player "abcdefgh"
    And player "abcdefgh" has a photo
    And player "abcdefgh" has a "found" photo
    When I go to the photos search page
    And I select "unfound" from "game_status"
    And I select "unconfirmed" from "game_status"
    And I press the keys "a" in the "#username" field
    And I wait until an "abcdefgh (1)" menu item appears
    And I click the "abcdefgh (1)" menu item
    And I press the "Search" button
    Then I should see search results for 1 photo

  @javascript
  Scenario: Player searches for a string which matches only the title
    Given there is a photo
    And the photo's "title" is "Fort Point Title"
    And the photo has a tag
    And the photo has a comment
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then I should see search results for 1 photo
    And I should see the photo's title with "Fort" and "Point" highlighted
    And I should see the photo's description
    And I should see the tag
    But I should not see the comment

  # This scenario is necessary because there's no way to tell a highlight in a tag from one in a different field
  @javascript
  Scenario: Player searches for a string which matches only a tag
    Given there is a photo
    And the photo has a tag "Fort Point Tag"
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then I should see search results for 1 photo
    And I should see the photo's title
    And I should see the photo's description
    And I should see the tag with "Fort" and "Point" highlighted

  # This scenario is necessary because there's no way to tell a highlight in a comment from one in a different field
  @javascript
  Scenario: Player searches for a string which matches only a comment
    Given there is a photo
    And the photo has a comment "Fort Point Comment"
    When I go to the photos search page
    And I fill in "text" with "Fort Point"
    And I press the "Search" button
    Then I should see search results for 1 photo
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
    Then I should see search results for 1 photo
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
    Then I should see a tag with "Fort" highlighted
    And I should see a tag with "Point" highlighted

  @javascript
  Scenario: Player searches for a comma-separated string which matches different comments
    Given there is a photo
    And the photo has a comment "It's a super-spectacular day"
    And the photo has a comment "I thought gentrification meant men dressing themselves carefully"
    When I go to the photos search page
    And I fill in "text" with "spectacular, gentrification"
    And I press the "Search" button
    Then I should see "It's a super-spectacular day" with "spectacular" highlighted
    And I should see "I thought gentrification meant men dressing themselves carefully" with "gentrification" highlighted
