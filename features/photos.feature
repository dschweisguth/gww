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
